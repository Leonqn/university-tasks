package magicalapps.server.routes

import magicalapps.server.app.Application._
import magicalapps.server.utils.spray.DirectoryPath
import magicalapps.server.database.entities.User
import magicalapps.server.database.services.HelpPointService
import spray.httpx.SprayJsonSupport._
import magicalapps.server.json.JsonResponseProtocol.responseJF
import magicalapps.server.json.HelpPointJsonProtocol.pointJF
import spray.json.CollectionFormats
import magicalapps.server.json.responses.JsonResponse._

trait HelpPointsRoutesGroup extends DirectoryPath with CollectionFormats {

    def groupHelpPoints(user: User) = dir("hp") {
        path("get") {
            parameters('lng.as[Double], 'lat.as[Double], 'side.as[Double]) { (lng, lat, sideSize) =>
                complete(
                    HelpPointService.selectFromSquare(lng, lat, sideSize)
                )
            }
        } ~
        path("set") {
            parameters('lng.as[Double], 'lat.as[Double]) { (lng, lat) =>
                HelpPointService.add(user.id, lng, lat)
                complete(jsonOk)
            }
        }
    }
}