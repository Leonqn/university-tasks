using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using HtmlAgilityPack;
using NyashApi.Models;

namespace NyashApi.NyashParseUtils
{
    public static class ParseUtilities
    {
        public static HtmlDocument GetPostById(uint id, PostType type)
        {
            var loader = new HtmlWeb
            {
                OverrideEncoding = Encoding.GetEncoding("windows-1251")
            };
            switch (type)
            {
                case PostType.Text:
                    return loader.Load(string.Format(TextPost, id));
                case PostType.Pic:
                    return loader.Load(string.Format(PicPost, id));
                case PostType.Irl:
                    return loader.Load(string.Format(IrlPost, id));
                default:
                    throw new Exception("wtf");
            }
        }

        public static bool Exists(HtmlDocument doc)
        {
            return
                doc.GetElementbyId("inner-body")
                    .ChildNodes.Any(node => node.Attributes.Any(attribute => attribute.Value == "q"));
        }

        public static TextPost ParseTextPost(HtmlDocument doc, uint id)
        {
            HtmlNode innerBody = doc.GetElementbyId("inner-body");
            List<HtmlNode> smAndContent =
                GetSmAndContent(innerBody);
            List<string> nameAndDate =
                GetNameAndDate(smAndContent[0]);
            string text = smAndContent[1].InnerText;
            return new TextPost
            {
                Author = nameAndDate[0],
                Date = nameAndDate[1],
                Id = id,
                Text =
                    HttpUtility.HtmlDecode(
                        Encoding.UTF8.GetString(Encoding.Convert(doc.Encoding, Encoding.UTF8,
                            doc.Encoding.GetBytes(text))))
            };
        }

        public static PicPost ParsePicPost(HtmlDocument doc, uint id)
        {
            HtmlNode innerBody = doc.GetElementbyId("inner-body");
            List<HtmlNode> smAndContent = GetSmAndContent(innerBody);
            List<string> nameAndDate = GetNameAndDate(smAndContent[0]);
            return new PicPost
            {
                Author = nameAndDate[0],
                Date = nameAndDate[1],
                Id = id,
                Pics =
                    smAndContent[1].FirstChild.ChildNodes.Where(
                        node => node.Attributes.Any(attribute => attribute.Value == "irl_pic"))
                        .Select(htmlNode => htmlNode.FirstChild.Name == "img"
                            ? new Images
                            {
                                Thumb = htmlNode.FirstChild.GetAttributeValue("src", null)
                            }
                            : new Images
                            {
                                Full = htmlNode.FirstChild.GetAttributeValue("href", null),
                                Thumb = htmlNode.FirstChild.FirstChild.GetAttributeValue("src", null)
                            }).ToList()
            };
        }

        private static List<string> GetNameAndDate(HtmlNode smAndContent)
        {
            return HttpUtility.HtmlDecode(smAndContent.Descendants().First(node => node.Name == "i").InnerText)
                .Split('—')
                .Select(s => s.Trim())
                .ToList();
        }


        private static List<HtmlNode> GetSmAndContent(HtmlNode innerBody)
        {
            return innerBody.ChildNodes
                .First(node => node.Attributes.Any(attribute => attribute.Value == "q"))
                .ChildNodes
                .Where(
                    node =>
                        node.Attributes.Any(attribute => attribute.Value == "sm" || attribute.Value == "content"))
                .ToList();
        }

        private const string TextPost = "http://nya.sh/post/{0}";
        private const string PicPost = "http://nya.sh/pic/{0}";
        private const string IrlPost = "http://nya.sh/irl/{0}";
    }

    public enum PostType
    {
        Text,
        Pic,
        Irl
    }
}