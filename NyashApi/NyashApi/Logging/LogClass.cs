using System.IO;
using log4net;
using log4net.Config;

namespace NyashApi.Logging
{
    public static class LogClass
    {
        static LogClass()
        {
            if (!LogManager.GetRepository().Configured)
                XmlConfigurator.ConfigureAndWatch(new FileInfo("log.config.xml"));
        }

        public static readonly ILog Logger = LogManager.GetLogger(typeof(LogClass));
    }
}