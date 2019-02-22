using System;
using System.Threading.Tasks;
using Microsoft.Owin;

namespace NyashApi.Logging
{
    public class LoggingMiddleware : OwinMiddleware
    {
        public LoggingMiddleware(OwinMiddleware next) : base(next)
        {
        }

        public override async Task Invoke(IOwinContext context)
        {
            LogClass.Logger.InfoFormat("METHOD: {0}; IP: {1}; PATH: {2}{3}",
                context.Request.Method,
                context.Request.RemoteIpAddress,
                context.Request.Path,
                context.Request.QueryString);
            try
            {
                await Next.Invoke(context);
            }
            catch (Exception e)
            {
                LogClass.Logger.Error("Error:", e);
            }

            LogClass.Logger.InfoFormat("ResponseCode: {0}", context.Response.StatusCode);
        }
    }
}