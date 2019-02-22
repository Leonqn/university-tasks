using System.IO;
using Newtonsoft.Json.Linq;

namespace NyashApi.Configs
{
    public static class MongoConfig
    {
        static MongoConfig()
        {
            JObject mongoConfig =
                JObject.Parse(
                    File.ReadAllText("settings/mongoSettings.json"));
            InitFields(mongoConfig);
        }

        private static void InitFields(JObject config)
        {
            Irls = config.Value<string>("colIrls");
            Pics = config.Value<string>("colPics");
            Texts = config.Value<string>("colTexts");
            Db = config.Value<string>("db");
        }
        
        public static string Irls;
        
        public static string Pics;
        
        public static string Texts;
        
        public static string Db;
    }
}