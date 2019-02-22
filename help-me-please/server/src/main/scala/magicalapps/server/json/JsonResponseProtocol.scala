package magicalapps.server.json

import spray.json._
import magicalapps.server.json.responses.JsonResponse

object JsonResponseProtocol extends DefaultJsonProtocol {

    implicit val responseJF = new RootJsonFormat[JsonResponse] {

        override def write(obj: JsonResponse) = JsObject(
            "message" -> obj.message.toJson,
            "status" -> obj.status.raw.toJson
        )

        override def read(json: JsValue) = ???
    }
}