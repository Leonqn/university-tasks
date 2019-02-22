using System.Collections.Generic;
using System.Web.Http;
using NyashApi.NyashParseUtils;

namespace NyashApi.Controllers
{
    [RoutePrefix("api/posts")]
    public class PostsController : ApiController
    {
        [Route(""), HttpGet]
        public IEnumerable<uint> GetLastId([FromUri] IEnumerable<string> lastIds)
        {
            return IncrementalParser.GetLastsPosts(lastIds);
        }
    }
}