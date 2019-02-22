using System.Web.Http;
using NyashApi.Configs;
using NyashApi.Containers;
using NyashApi.Models;

namespace NyashApi.Controllers
{
    [RoutePrefix("api/posts/texts")]
    public class TextPostsController : TypedPostsControllerBase<TextPost>
    {
        protected TextPostsController() : base(new PostsContainer<TextPost>(MongoConfig.Db, MongoConfig.Texts))
        {
        }
    }
}