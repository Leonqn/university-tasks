open RabbitMQ.Client
open RabbitMQ.Client.Events;
open System
open System.Diagnostics
open System.Threading

let getCpuUsage =
    use counter = new PerformanceCounter("Processor", "% Processor Time", "_Total")
    fun () -> counter.NextValue()

let getFreeRam =
    use counter = new PerformanceCounter("Memory", "Available MBytes")
    fun () -> counter.NextValue()

let sendStats hostName =
    let id = Environment.MachineName.Replace(".", "") + "_" + Process.GetCurrentProcess().Id.ToString()
    let factory = ConnectionFactory(HostName = hostName)
    use connection = factory.CreateConnection()
    use channel = connection.CreateModel()
    channel.ExchangeDeclare("perf", "topic")
    while true do
        channel.BasicPublish("perf", "cpu." + id, null, BitConverter.GetBytes (getCpuUsage ()))
        channel.BasicPublish("perf", "ram." + id, null, BitConverter.GetBytes (getFreeRam ()))
        Thread.Sleep 5000

let recieveStats hostName =
    let factory = ConnectionFactory(HostName = hostName)
    use connection = factory.CreateConnection()
    use channel = connection.CreateModel()
    channel.ExchangeDeclare("perf", "topic")

    let listen rk = 
        let queueName = channel.QueueDeclare().QueueName
        channel.QueueBind(queueName, "perf", rk)
        let consumer = new EventingBasicConsumer(channel)
        consumer.Received 
        |> Event.map (fun x -> x.RoutingKey.Split('.').[1], BitConverter.ToSingle(x.Body, 0))
        |> Event.add (fun (id, value) -> printfn "%s %s %f" (rk.Substring(0, 3)) id value)
        channel.BasicConsume(queueName, true, consumer) |> ignore

    listen "cpu.*" 
    listen "ram.*"
    Console.ReadLine() |> ignore

[<EntryPoint>]
let main args =
    match args with
    | [| "sender"; hostName |] -> sendStats hostName
    | [| "reciever"; hostName |] -> recieveStats hostName
    | _ -> printfn "specify sender or reciever"
    0