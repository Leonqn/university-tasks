using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using NyashApi.Containers;
using NyashApi.Models;

namespace NyashApi.Controllers
{
    public abstract class TypedPostsControllerBase<T> : ApiController where T : Post
    {
        protected TypedPostsControllerBase(PostsContainer<T> postsContainer)
        {
            this.postsContainer = postsContainer;
        }

        [Route(""), HttpGet]
        public IEnumerable<T> Get([FromUri] uint[] ids)
        {
            return ids == null || !ids.Any() ? postsContainer.GetAll() : postsContainer.Select(ids);
        }

        [Route("{id}"), HttpGet]
        public T Get(uint id)
        {
            return postsContainer.Get(id);
        }

        private readonly PostsContainer<T> postsContainer;
    }
}