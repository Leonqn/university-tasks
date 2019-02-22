namespace Mq.Coordinator

module Handler =
    open Suave
    open Suave.Operators
    open Suave.Filters
    open Suave.Successful
    open Suave.Writers
    open Suave.RequestErrors
    open Mq.Core

    let auth authorize protectedAction (ctx: HttpContext) = async {
        let authHeader = ctx.request.header "authorization"
        match authHeader with
        | Choice1Of2 h ->
            let! authResult = authorize h
            match authResult with
            | Some x ->
                return! FORBIDDEN x ctx
            | None ->
                return! protectedAction ()
            
        | Choice2Of2 _ ->
            return! forbidden [||] ctx
    }
        

    let handle tryAuthorize stopTask =
        POST
        >=> pathScan "/tasks/%i/stop" 
                (fun taskId ctx ->
                    auth 
                        (tryAuthorize taskId) 
                        (fun _ -> stopTask taskId |> Async.bind (fun _ -> NO_CONTENT ctx))
                        ctx)
        >=> setMimeType "application/json; charset=utf-8"
        <|> NOT_FOUND "Resource not found."


module ApiRequests = 
    open System.IO
    open System.Text
    open FSharp.Data
    open Mq.Core
    open System.Net

    let tryAuthorize tasksApiUrl taskId authorizationHeader = async {
        let! response = 
            Http.AsyncRequest
                (string tasksApiUrl,
                ["id", (sprintf "eq.%i" taskId)],
                ["content-type", "application/json"; "authorization", authorizationHeader],
                "PATCH",
                HttpRequestBody.BinaryUpload <| Encoding.UTF8.GetBytes (sprintf """{"id": %i}""" taskId),
                silentHttpErrors = true)
        
        match response.StatusCode with
        | _ -> 
            return None
        | x when x > 300 ->
            return 
                match response.Body with
                | Text text ->
                    text
                | Binary bin ->
                    Encoding.UTF8.GetString bin
                |> Some
    }

module ExecutorRequests = 
    open FSharp.Data
    open System.IO
    open Chiron
    open Mq.Core
   
    let private combine x y = Path.Combine(x, y)

    let stopTask executorUrl = 
        Http.AsyncRequest
            (combine (string executorUrl) "stop",
            httpMethod = "POST",
            silentHttpErrors = true)

    let getCurrentTasks executors =
        let getTask executorUrl =
            Http.AsyncRequestString
                (combine executorUrl "hb",
                httpMethod = "GET",
                silentHttpErrors = true)
            |> Async.map (Json.parse >> Json.deserialize >> function | Some (x: int) -> Some(x, executorUrl) | None -> None)
        
        executors
        |> List.map getTask
        |> Async.Parallel
        |> Async.map (Array.choose id)
        |> Async.map Map.ofArray

module Coordination =
    open Mq.Core

    let stop getCurrentTasks stopTask = 
        let handle state (ch, taskId) = async {
            match Map.tryFind taskId state with
            | Some executorUrl ->
                do! stopTask executorUrl
                Agent.reply ch ()
                return state
            | None ->
                let! state = getCurrentTasks ()
                match Map.tryFind taskId state with
                | Some executorUrl ->
                    do! stopTask executorUrl
                | None -> ()
                Agent.reply ch ()
                return state
        }

        let agent =
            Agent.start Map.empty handle

        fun (taskId: int) ->
            agent.PostAndAsyncReply (fun ch -> ch, taskId)

