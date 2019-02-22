using System;
using System.Collections.Generic;
using System.Threading;
using HtmlAgilityPack;
using NyashApi.Configs;
using NyashApi.Containers;
using NyashApi.Logging;
using NyashApi.Models;

namespace NyashApi.NyashParseUtils
{
    public class IncrementalParser
    {
        public IncrementalParser()
        {
            textPostsContainer = new PostsContainer<TextPost>(MongoConfig.Db, MongoConfig.Texts);
            picPostsContainer = new PostsContainer<PicPost>(MongoConfig.Db, MongoConfig.Pics);
            irlPostsCointaner = new PostsContainer<PicPost>(MongoConfig.Db, MongoConfig.Irls);
            lastTextPost = textPostsContainer.GetLastId();
            lastPicPost = picPostsContainer.GetLastId();
            lastIrlPost = irlPostsCointaner.GetLastId();
        }

        public void Start()
        {
            new Thread(() =>
            {
                while (true)
                {
                    try
                    {
                        lastTextPost = UpdateLastPost(lastTextPost, PostType.Text);
                        lastPicPost = UpdateLastPost(lastPicPost, PostType.Pic);
                        lastIrlPost = UpdateLastPost(lastIrlPost, PostType.Irl);
                        Thread.Sleep(TimeSpan.FromMinutes(20));
                    }
                    catch (Exception e)
                    {
                        LogClass.Logger.Error("Parse error", e);
                    }
                }
            }) {IsBackground = true}.Start();
        }

        public static IEnumerable<uint> GetLastsPosts(IEnumerable<string> types)
        {
            foreach (string type in types)
            {
                switch (type)
                {
                    case "pics":
                        yield return lastPicPost;
                        break;
                    case "irls":
                        yield return lastIrlPost;
                        break;
                    case "texts":
                        yield return lastTextPost;
                        break;
                }
            }
        }

        private uint UpdateLastPost(uint lastPost, PostType type)
        {
            uint postsCount = lastPost + 1;
            while (postsCount < lastPost + 10)
            {
                HtmlDocument postById = ParseUtilities.GetPostById(postsCount, type);
                if (ParseUtilities.Exists(postById))
                {
                    switch (type)
                    {
                        case PostType.Text:
                            textPostsContainer.InsertOrUpdatePost(ParseUtilities.ParseTextPost(postById, postsCount));
                            break;
                        case PostType.Pic:
                            picPostsContainer.InsertOrUpdatePost(ParseUtilities.ParsePicPost(postById, postsCount));
                            break;
                        case PostType.Irl:
                            irlPostsCointaner.InsertOrUpdatePost(ParseUtilities.ParsePicPost(postById, postsCount));
                            break;
                    }

                    lastPost = postsCount;
                    postsCount++;
                }
                else
                    postsCount++;
            }
            return lastPost;
        }
        private static uint lastTextPost;
        private static uint lastPicPost;
        private static uint lastIrlPost;

        private readonly PostsContainer<PicPost> irlPostsCointaner;
        private readonly PostsContainer<PicPost> picPostsContainer;
        private readonly PostsContainer<TextPost> textPostsContainer;
    }
}