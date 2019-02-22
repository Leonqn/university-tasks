package magicalapps.server.json.responses

import magicalapps.server.json.responses.JsonResponseStatus._

case class JsonResponse(message: String, status: JsonResponseStatus)

object JsonResponse {

    val jsonOk = JsonResponse("request completed successfully", ok)

    def jsonError(message: String) = JsonResponse(message, error)
}