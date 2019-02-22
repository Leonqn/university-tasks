using System.Web.Http;
using NyashApi.Configs;
using NyashApi.Containers;
using NyashApi.Models;

namespace NyashApi.Controllers
{
    [RoutePrefix("api/posts/pics")]
    public class PicPostsController : TypedPostsControllerBase<PicPost>
    {
        public PicPostsController()
            : base(new PostsContainer<PicPost>(MongoConfig.Db, MongoConfig.Pics))
        {
        }
    }
}