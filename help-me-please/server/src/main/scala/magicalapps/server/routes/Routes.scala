package magicalapps.server.routes

import magicalapps.server.app.Application._
import magicalapps.server.database.services.UserService.register
import spray.httpx.SprayJsonSupport._
import magicalapps.server.json.JsonResponseProtocol.responseJF
import magicalapps.server.json.responses.JsonResponse._

object Routes extends HelpPointsRoutesGroup {

    val $ = clientIP { implicit ip =>
        get {
            pathPrefix("api" / ".+".r) { token =>
                register(token).map { user =>
                    groupHelpPoints(user)
                 // ~
                 // groupWhatever
                }.getOrElse {
                    complete(jsonError("authorization failed"))
                }
            }
        } ~
        complete(jsonError("unknown route"))
    }
}