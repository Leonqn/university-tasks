namespace Mq.Executor

module Handlers = 
    open Suave
    open Suave.Filters
    open Suave.Operators
    open Mq.Core.Suave.Json
    open Suave.RequestErrors
    open Mq.Core

    let inline handle (executor: IExecutor) = 
        choose
            [ GET 
              >=> path "/hb" 
              >=> fun ctx -> 
                    executor.TryGetCurrentTaskId ()
                    |> Async.bind (fun taskId -> Response.response HTTP_200 taskId ctx) 
              POST
              >=> path "/stop"
              >=> fun ctx -> 
                    executor.StopCurrentExecution()
                    |> Async.bind (fun _ -> Response.response HTTP_204 "" ctx)
              NOT_FOUND "Resource not found." ]
