package magicalapps.server.json.responses

case class JsonResponseStatus(raw: String)

object JsonResponseStatus {

    val ok = JsonResponseStatus("ok")

    val error = JsonResponseStatus("error")
}