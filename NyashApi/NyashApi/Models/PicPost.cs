using System.Collections.Generic;

namespace NyashApi.Models
{
    public class PicPost : Post
    {
        public IList<Images> Pics { get; set; }
    }
}