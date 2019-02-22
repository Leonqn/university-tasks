namespace Mq.Core

module Suave =

    module Logging = 
        open Suave.Logging

        let nlogLogger = 
            let logger = NLog.FSharp.Logger()
            let logLogline (log: Printf.StringFormat<_, unit> -> _) (logEx: System.Exception -> Printf.StringFormat<_, unit> -> _) logLine =
                let logLine = logLine ()
                match logLine.``exception`` with
                | Some exn -> logEx exn "[%s] %s" logLine.path logLine.message
                | None -> log "[%s] %s" logLine.path logLine.message

            { new Logger with
                  member __.Log logLevel logLine = 
                    match logLevel with
                    | LogLevel.Info ->  logLogline logger.Info logger.InfoException logLine
                    | LogLevel.Verbose
                    | LogLevel.Debug -> logLogline logger.Debug logger.DebugException logLine
                    | LogLevel.Error -> logLogline logger.Error logger.ErrorException logLine
                    | LogLevel.Fatal -> logLogline logger.Fatal logger.FatalException logLine 
                    | LogLevel.Warn -> logLogline logger.Warn logger.WarnException logLine }

    module Json =

        module Response =
            open Chiron
            open Suave.Writers
            open Suave.Operators
            open Suave.Response
            open System.Text

            let inline toJson x =
                Json.serialize x |> Json.format |> Encoding.UTF8.GetBytes
        
            let inline response httpStatus obj =
                let serialized = obj |> toJson
                response httpStatus serialized >=> setMimeType "application/json; charset=utf-8"

        module Request =
            open Chiron
            open Suave
            open System.Text

            let inline fromJson x =
                x |> Encoding.UTF8.GetString |> Json.parse |> Json.deserialize

            let inline request f (x: HttpContext) =
                x.request.rawForm
                |> fromJson
                |> f
