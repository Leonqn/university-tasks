using System;
using System.Net;
using Microsoft.Owin.Hosting;
using NyashApi.Logging;
using NyashApi.NyashParseUtils;

namespace NyashApi
{
    public class EntryPoint
    {
        private static void Main(string[] args)
        {
            ServicePointManager.DefaultConnectionLimit = 16;
            new IncrementalParser().Start();
            WebApp.Start<Startup>("http://+:2248");
            LogClass.Logger.Info("Server started");
            Console.ReadKey(true);
        }
    }
}