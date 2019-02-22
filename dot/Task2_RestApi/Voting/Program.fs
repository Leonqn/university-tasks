open Suave
open Suave.Filters
open Suave.Operators
open Suave.Successful
open System
open System.Collections.Concurrent
open Suave.Writers
open System.Net
open Suave.RequestErrors
open System.IO


type Bulletin =
    | One
    | Two
    | Three
    | Wtf
    static member GetCases () = sprintf "one, two, three"
    static member Parse (case: string) =
        match case.ToLower() with
        | "one" -> One
        | "two" -> Two
        | "three" -> Three
        | _ -> Wtf

type Result<'TSuccess, 'TFailure> =
    | Success of 'TSuccess
    | Failure of 'TFailure

type DomainMessage = 
    | UserAlreadyExists
    | UserAlreadyVoted
    | ThereIsNoResults
    | UserDoesNotExists

module Voting =
    let private usersMap = ConcurrentDictionary<string, Guid>()
    let private votingMap = ConcurrentDictionary<Guid, Bulletin>()

    let getBulletin = Bulletin.GetCases >> Success

    let registerVoter name = 
        let guid = Guid.NewGuid()
        if usersMap.TryAdd(name, guid) then Success guid else Failure UserAlreadyExists

    let vote userId option =
        if usersMap.Values.Contains userId then
            if votingMap.TryAdd(userId, option) then Success "" else Failure UserAlreadyVoted
        else Failure UserDoesNotExists

    let getResults () =
        if usersMap.IsEmpty then Failure ThereIsNoResults
        else usersMap |> Seq.map (fun x -> x.Key, votingMap.TryGetValue x.Value |> function | true, x -> Some x | _ -> None) |> Success

    let reset () =
        usersMap.Clear()
        votingMap.Clear()

let app =
    let mapResult = function
    | Success x -> sprintf "%A" x |> OK
    | Failure x ->
        match x with
        | UserAlreadyExists -> CONFLICT "user already exists"
        | UserAlreadyVoted -> FORBIDDEN "user already voted"
        | ThereIsNoResults -> NOT_FOUND "there is no results"
        | UserDoesNotExists -> Response.response HTTP_401 [||]
    
    let userId f (context: HttpContext) =
        let guid = ref Guid.Empty
        context.request.header "Authorization" 
        |> function 
           | Choice1Of2 x when Guid.TryParse(x, guid) -> f !guid context
           | _ -> Response.response HTTP_401 [||] context
    
    let cors handlers =
        OPTIONS >=> pathStarts "/" >=> OK ""
        <|> handlers
        >=> setHeader "Access-Control-Allow-Origin" "*"
        >=> setHeader "Access-Control-Allow-Methods" "POST,GET,PUT,DELETE"
        >=> setHeader "Access-Control-Allow-Headers" "Accept, Origin, Content-type, Authorization"

    let swagger =
        GET >=> path "/voting/_swagger" 
        >=> (File.ReadAllText (Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "voting-api-swagger.json")) |> OK >=> setMimeType "application/json")

    let bulletins = 
        choose
            [ GET >=> path "/voting/bulletin" >=> fun x -> (Voting.getBulletin () |> mapResult) x
              PUT >=> pathScan "/voting/bulletin/%s" (Bulletin.Parse >> fun x -> userId (fun uid -> Voting.vote uid x |> mapResult)) ]

    let results =
        GET >=> path "/voting/results" >=> fun x -> (Voting.getResults () |> mapResult) x

    let voters =
        PUT >=> pathScan "/voting/voters/%s" (fun x -> x |> Voting.registerVoter |> mapResult >=> setStatus HTTP_201)

    let reset =
        POST >=> path "/voting/_reset" >=> fun x -> Voting.reset(); OK "" x
    
    let notFound = RequestErrors.NOT_FOUND "Found no handlers"

    choose [ bulletins; voters; results; reset; swagger; notFound ] |> cors

[<EntryPoint>]
let main argv = 
    match argv with
    | [| port |] -> 
        let port = UInt16.Parse port
        let config = { defaultConfig with bindings = [ HttpBinding.mk HTTP IPAddress.Any port ] }
        startWebServer config app
    | _ -> printf "You should specify port as first command line argument"

    0
