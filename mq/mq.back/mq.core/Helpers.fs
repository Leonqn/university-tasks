namespace Mq.Core

module Operators =
    let (=>) x y = x, y :> obj

[<AutoOpen>]
module Common =
    open System.Runtime.ExceptionServices

    let rethrow ex =
        ExceptionDispatchInfo.Capture(ex).Throw()
        failwith "nothing to return, but will never get here"


module Choice =
    let toOption = function
        | Choice1Of2 x -> Some x
        | Choice2Of2 _ -> None
        

module Agent =

    let start initState handleMsg =
        MailboxProcessor.Start(
            fun inbox ->
                let rec loop state = async {
                    let! msg = inbox.Receive()
                    let! newState = handleMsg state msg
                    return! loop newState

                }
                loop initState)


    let reply (ch: AsyncReplyChannel<_>) x =
        ch.Reply x

module Async = 
    open System

    let map f x = async {
        let! x' = x
        return f x'
    }

    let bind f x = async {
        let! x' = x
        return! f x'
    }

    let ignore x = map ignore x

    let logEx (log: System.Exception -> Printf.StringFormat<_, unit> -> _) x = async {
        try 
            let! x' = x
            return x'
        with 
        | ex -> 
            log ex "%s" "Unexpected error occured"
            return rethrow ex
    }

    let tryInfinite x =
        let initWait = 5000
        let maxWait = 120000
        let rec loop x waitFor = async {
            try 
                let! x' = x
                return x'
            with
            | _ -> 
                do! Async.Sleep waitFor
                return! loop x <| Math.Min(maxWait, waitFor * 2)
        }
        loop x initWait


module Routine =
    open System.Threading
    open System
    open NLog.FSharp

    let private log = Logger()

    let startInBackground execute =
        let rec executionLoop _ = 
            try
                execute ()
                Thread.Sleep 5000
            with
            | :? ThreadAbortException -> 
                log.Info "Exectuion thread stopped"
                reraise ()
            | ex -> 
                log.ErrorException ex "Some unexpected error occured"
            executionLoop ()
        
        let thread = Thread(executionLoop, IsBackground = true)
        thread.Start()
        { new IDisposable with
              member __.Dispose()  = 
                  thread.Abort() }