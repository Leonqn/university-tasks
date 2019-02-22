using System;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Driver;
using MongoDB.Driver.Linq;
using NyashApi.Logging;
using NyashApi.Models;

namespace NyashApi.Containers
{
    public class PostsContainer<T> where T : Post
    {
        public PostsContainer(string db, string collection)
        {
            try
            {
                postsCollection = new MongoClient().GetServer().GetDatabase(db).GetCollection<T>(collection);
            }
            catch (Exception e)
            {
                LogClass.Logger.Error("Mongo error", e);
                throw;
            }
        }

        public void InsertOrUpdatePost(T post)
        {
            postsCollection.Save(post);
        }

        public T Get(uint id)
        {
            return postsCollection.AsQueryable().FirstOrDefault(post => post.Id == id);
        }

        public IEnumerable<T> GetAll()
        {
            return postsCollection.AsQueryable();
        }

        public IEnumerable<T> Select(IEnumerable<uint> ids)
        {
            return postsCollection.AsQueryable().Where(arg => arg.Id.In(ids));
        }

        public uint GetLastId()
        {
            return postsCollection.AsQueryable().OrderByDescending(arg => arg.Id).First().Id;
        }

        private readonly MongoCollection<T> postsCollection;
    }
}