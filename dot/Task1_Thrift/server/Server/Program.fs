open FSharp.Data
open Thrift.Transport
open System.Collections.Generic
open OpenGraph
open Thrift.Protocol
open System.Net
open System.Threading.Tasks
open System
open System.Threading

module OpenGraph =

    let extractMetaFromHtml =
        let chooseMeta node = 
            match HtmlNode.tryGetAttribute "property" node, HtmlNode.tryGetAttribute "content" node with
            | Some prop, Some content when prop.Value().StartsWith "og:" -> 
                Some (prop.Value().ToLower(), content.Value())
            | _ -> 
                None

        let foldToMeta (acc: OpenGraphMeta) = function
            | "og:title", x -> acc.Title <- x; acc
            | "og:type", x -> acc.Type <- x; acc
            | "og:url", x -> acc.Url <- x; acc
            | "og:image", x -> acc.Image <- x; acc
            | other, x -> if acc.Additional.ContainsKey other then acc else acc.Additional.Add(other, x); acc
        
        HtmlDocument.descendantsNamed true ["meta"]
        >> Seq.choose chooseMeta
        >> Seq.toList
        >> function | [] -> raise <| MetaAbsentException () | x -> Seq.fold foldToMeta (OpenGraphMeta(Additional = Dictionary<string, string>())) x

module Http =
   
    let handleRequests listenPrefixes (handler: THttpHandler) =
        let listen (listener: HttpListener) =
            while true do
                let context = listener.GetContext()
                context.Response.AddHeader("Access-Control-Allow-Origin", "*")
                context.Response.AddHeader("Access-Control-Allow-Methods", "POST,GET,PUT,DELETE")
                context.Response.AddHeader("Access-Control-Allow-Headers", "Accept, Content-type")
                if context.Request.HttpMethod = "OPTIONS" then
                    context.Response.OutputStream.Close()
                else 
                    Task.Run (fun _ -> handler.ProcessRequest(context)) |> ignore
        
        let listener = new HttpListener()
        listener.Prefixes.Add listenPrefixes
        listener.Start()
        let listenThread = Thread(ThreadStart(fun _ -> listen listener), IsBackground = true)
        listenThread.Start()

    let get (url: string) =
        try
            HtmlDocument.Load url
        with
        | :? WebException as ex -> 
            match ex.Response with
            | :? HttpWebResponse as r when r.StatusCode = HttpStatusCode.NotFound -> raise <| NotFoundException ()
            | _ -> raise <| NetException ()
        | _ -> raise <| UnknownException ()

type OpenGraphServiceHanlder(httpGet: string -> HtmlDocument, parseProps: HtmlDocument -> OpenGraphMeta) =
    interface OpenGraphService.Iface with
        member __.GetMeta url = url |> httpGet |> parseProps
        
[<EntryPoint>]
let main argv = 
    match argv with
    | [| prefix |] ->
        let openGraphServiceHanlder = OpenGraphServiceHanlder(Http.get, OpenGraph.extractMetaFromHtml)
        let processor = OpenGraphService.Processor(openGraphServiceHanlder)
        let protocolFactory = 
            { new TProtocolFactory with
                member __.GetProtocol(trans) = new TJSONProtocol(trans) :> TProtocol }
        let httpHanlder = THttpHandler(processor, protocolFactory)
        printfn "Starting the server"
        Http.handleRequests prefix httpHanlder
        Console.ReadKey() |> ignore
    | _ -> 
        printfn "You should specify prefix to listen by http server in console argument."
    0