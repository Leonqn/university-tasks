open Mq.Executor
open Npgsql
open FSharp.Configuration
open System
open Mq.Core

type Config = YamlConfig<"config.example.yml">

let buildExecutor (config: Config) =
    let connection = new NpgsqlConnection(config.Db.ConnectionString)

    let fetchTask = fun _ -> Db.Requests.dequeueTask connection
    let getPrograms = Db.Requests.getPrograms connection
    let completeAndInsert = Db.Requests.completeAndInsert connection
    let executePograms = Execution.executeFirst config.Octave.Path

    Executor(fetchTask, getPrograms, executePograms, completeAndInsert)


[<EntryPoint>]
let main argv = 
    let config : Config = Configuration.get ()
    let executor : IExecutor = buildExecutor config :> IExecutor
    use __ = Routine.startInBackground (executor.ExecuteNext >> Async.RunSynchronously)
    let handler = Handlers.handle executor
    let suaveConfig = { Suave.Web.defaultConfig with         
                            logger = Mq.Core.Suave.Logging.nlogLogger
                            bindings = [Suave.Http.HttpBinding.mkSimple Suave.Http.Protocol.HTTP "0.0.0.0" config.Api.Port] }
    Suave.Web.startWebServer suaveConfig handler 
    Console.ReadLine () |> ignore
    0 // return an integer exit code