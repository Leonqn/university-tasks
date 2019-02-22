namespace csharp OpenGraph
namespace js OpenGraph
typedef string url

struct OpenGraphMeta {
    1: string title,
    2: string type,
    3: string image,
    4: string url,
    5: optional map<string, string> additional,
}

exception NetException {}
exception NotFoundException {}
exception UnknownException {}
exception MetaAbsentException {}

service OpenGraphService {

    OpenGraphMeta GetMeta(1: url url) throws (1: NetException netEx, 2: NotFoundException notFoundEx, 3: UnknownException unkEx, 4: MetaAbsentException metaEx)
}