using System.Web.Http;
using NyashApi.Configs;
using NyashApi.Containers;
using NyashApi.Models;

namespace NyashApi.Controllers
{
    [RoutePrefix("api/posts/irls")]
    public class IrlPostsController : TypedPostsControllerBase<PicPost>
    {
        public IrlPostsController() : base(new PostsContainer<PicPost>(MongoConfig.Db, MongoConfig.Irls))
        {

        }
    }
}