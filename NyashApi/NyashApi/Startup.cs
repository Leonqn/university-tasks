using System.Collections.Generic;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Routing;
using NyashApi.Logging;
using Owin;

namespace NyashApi
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            var config = new HttpConfiguration();
            config.MapHttpAttributeRoutes(new CustomDirectRouteProvider());
            app.Use<LoggingMiddleware>();
            app.UseWebApi(config);
        }

        private class CustomDirectRouteProvider : DefaultDirectRouteProvider
        {
            protected override IReadOnlyList<IDirectRouteFactory> GetActionRouteFactories(
                HttpActionDescriptor actionDescriptor)
            {
                return actionDescriptor.GetCustomAttributes<IDirectRouteFactory>(true);
            }
        }
    }
}