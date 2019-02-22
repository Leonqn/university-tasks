namespace Mq.Core

module Configuration = 

    open System.IO
    open System
    open FSharp.Configuration

    let inline get<'Config when 'Config :> YamlConfigTypeProvider.Root and 'Config : (new : unit -> 'Config)> ()  =
        let config = new ^Config()
        config.Load(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "settings/config.yml"))
        config