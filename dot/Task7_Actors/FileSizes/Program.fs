open System.Reflection
open Orleankka             
open Orleankka.FSharp   
open Orleankka.Playground 
open System.IO
open System
open System.Threading.Tasks

module Task = 
    let unwrap (task: Task<Task<_>>) = task.Unwrap()

type FilesList = FilesList of workers:ActorRef[]*string[]

type WorkerMessage =
    | GetFileSize of string
    | CountFileSizes of int64[]

type Worker() =
    inherit Actor<WorkerMessage>()
    
    override __.Receive message =
        printfn "Got request. Worker %s" __.Id
        match message with 
        | GetFileSize fileName ->
            response >> Task.returnM <| FileInfo(fileName).Length
        | CountFileSizes sizes ->
            response >> Task.returnM <| Array.sum sizes

type Master() =
    inherit Actor<FilesList>()
       
    let rng = Random()

    let getWorker workersPool =
        workersPool |> Array.item (rng.Next(0, workersPool.Length))

    override __.Receive (FilesList(workersPool, fileNames)) =
        printfn "Got request. Master %s" __.Id
        fileNames 
        |> Array.map (fun x -> getWorker workersPool <? GetFileSize x)
        |> Task.whenAll CountFileSizes
        |> Task.map ((<?) (getWorker workersPool))
        |> Task.unwrap


[<EntryPoint>]
let main _ = 
    use system = ActorSystem
                    .Configure()
                    .Playground()
                    .Register(Assembly.GetExecutingAssembly())
                    .Done()
    printfn "Started"
    let master = system.ActorOf<Master>("master")
    let workersPool = Array.init 10 (fun i -> system.ActorOf<Worker>(i.ToString()))
    while true do
        printfn "Type file names"
        let fileNames = Console.ReadLine() |> fun x -> x.Split ' '
        let job () = master <? FilesList(workersPool, fileNames)
        Task.run job |> printfn "Task result: %A"
    0