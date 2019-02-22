namespace Mq.Executor

open System.Threading
open NLog.FSharp
open Mq.Core
open Db.Model

type FunctionDefenition = 
    { Name: string
      Code: string }

type ExecutionStatus =
    | Ok of byte array
    | Failed of byte array
    | Aborted of byte array


module IOUtils =
    open System.IO
    open System.IO.Compression
    open System
    open System.Diagnostics

    let saveFunDefs basePath funDefns =
        Directory.CreateDirectory basePath |> ignore
        Seq.iter (fun x -> File.WriteAllText(Path.Combine(basePath, x.Name + ".m"), x.Code)) funDefns
    
    let saveStderr basePath (proc: Process) =
        Directory.CreateDirectory basePath |> ignore
        let stdErr = proc.StandardError.ReadToEnd()
        if not <| String.IsNullOrEmpty stdErr then
            File.WriteAllText(Path.Combine(basePath, "stderr"), stdErr)

    let clear path =
        Directory.Delete(path, true)

    let zip path =
        let archiveLocation = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tmp.zip")
        File.Delete archiveLocation
        ZipFile.CreateFromDirectory(path, archiveLocation, CompressionLevel.Optimal, false)
        File.ReadAllBytes(archiveLocation)

module Execution =
    open System.Text.RegularExpressions
    open System
    open System.IO
    open System.Diagnostics
    open System.Threading
     
    let private (|Regex|_|) pattern input =
        let m = Regex.Match(input, pattern)
        if m.Success then Some([ for g in m.Groups -> g.Value ])
        else None

    let private extractFunDef code = 
        match code with
        | Regex @"function(.*?=)?\s*(\w+)\s*" [_; _; name] ->
            { Name = name; Code = code }
        | _ -> 
            { Name = "script"; Code = code }

    let executeFirst octavePath programs (ct: CancellationToken) = async {
        let basePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "source")
        let funDefs = Seq.map ((fun (x: Program) -> x.Code) >> extractFunDef) programs |> Seq.toList
        match funDefs with
        | entryPoint::_ ->
            IOUtils.saveFunDefs basePath funDefs
            let args = sprintf "--eval \"cd ('%s'); diary on; %s\"" basePath entryPoint.Name
            let isAborted = ref false
            let startInfo =
                ProcessStartInfo(octavePath, args,
                    RedirectStandardError = true,
//                    RedirectStandardOutput = true,
                    UseShellExecute = false
                    )
            let proc = Process.Start(startInfo)
            use __ = ct.Register(fun _ -> try proc.Kill(); isAborted := true with _ -> ())
            while not proc.HasExited do
                do! Async.Sleep 100
            IOUtils.saveStderr basePath proc
            let result = IOUtils.zip basePath
            IOUtils.clear basePath
            return 
                match proc.ExitCode, !isAborted with
                | 0, _ -> Ok result
                | _, false -> Failed result
                | _, true -> Aborted result

        | _ -> 
            return Failed null
    }



type IExecutor =
    abstract member ExecuteNext: unit -> Async<unit>
    abstract member TryGetCurrentTaskId: unit -> Async<int option>
    abstract member StopCurrentExecution: unit -> Async<unit>

type private ExecutorMsg =
        | TryGetCurrentTask of AsyncReplyChannel<Task option>
        | TryExecuteNext of AsyncReplyChannel<unit>
        | Stop of AsyncReplyChannel<Unit>

type Executor(fetchTask: unit -> Async<Task option>, getPrograms: int -> Async<Program seq>, executeFirst, completeAndInsert) =
    let logger = Logger()

    let reply (ch: AsyncReplyChannel<_>) x =
        ch.Reply x


    let stop ch state =
        match state with
        | Some (_, cts: CancellationTokenSource) ->
            cts.Cancel()
            reply ch ()
            None
        | x ->
            reply ch ()
            x

    let tryGetCurrentTask ch state = 
        reply ch <| Option.map fst state
        state

    let tryExecuteNext ch _ = async {
        let createExecutionTask (task: Task) ch (ct: CancellationToken) = async {
            let! programs = 
                getPrograms task.Program
                |> Async.logEx logger.ErrorException
                |> Async.tryInfinite
                |> Async.map (Seq.fold (fun acc x -> if x.Id = task.Program then x :: acc else List.append acc [ x ]) [])

            let! executionStatus = 
                executeFirst programs ct 
                |> Async.logEx logger.ErrorException
                |> Async.Catch
                |> Async.map (function | Choice1Of2 x -> x | Choice2Of2 _ -> Failed [||])

            let status, content = 
                match executionStatus with
                | Ok content -> "ok", content
                | Failed content -> "failed", content
                | Aborted content -> "aborted", content
            logger.Info "Task %i executed with status %s" task.Id status
            let result =
                { Author = task.Author
                  Task = task.Id 
                  Program = task.Program
                  Content = content
                  Args = null
                  Status = status }
            do! completeAndInsert task result
                |> Async.logEx logger.ErrorException
                |> Async.tryInfinite
            reply ch ()
        }

        logger.Info "Trying fetch new task"
        let! task = 
            fetchTask () 
            |> Async.logEx logger.ErrorException
            |> Async.Catch 
            |> Async.map (function | Choice1Of2 x -> x | _ -> None)

        match task with
        | Some task ->
           logger.Info "Got task with id %i and author %s" task.Id task.Author
           let cts = new CancellationTokenSource()
           createExecutionTask task ch cts.Token |> Async.Start
           return Some(task, cts)
        | None -> 
            reply ch ()
            return None
    }

    let handle state msg = async {
        match msg with
        | Stop ch -> 
            return stop ch state
                           
        | TryGetCurrentTask ch ->
            return tryGetCurrentTask ch state

        | TryExecuteNext ch ->
            return! tryExecuteNext ch state
    }

    let agent = Agent.start None handle


    interface IExecutor with

        member __.ExecuteNext() =
            agent.PostAndAsyncReply TryExecuteNext

        member __.TryGetCurrentTaskId() =
            agent.PostAndAsyncReply TryGetCurrentTask |> (Async.map << Option.map) (fun x -> x.Id)

        member __.StopCurrentExecution() =
            agent.PostAndAsyncReply Stop
        