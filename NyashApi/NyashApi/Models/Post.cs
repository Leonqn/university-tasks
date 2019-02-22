namespace NyashApi.Models
{
    public abstract class Post
    {
        public uint Id { get; set; }

        public string Author { get; set; }

        public string Date { get; set; }
    }
}