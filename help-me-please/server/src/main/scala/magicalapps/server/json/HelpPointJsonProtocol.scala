package magicalapps.server.json

import spray.json._
import magicalapps.server.database.entities.HelpPoint

object HelpPointJsonProtocol extends DefaultJsonProtocol {

    import TimestampJsonProtocol.timestampJF

    implicit val pointJF = jsonFormat(HelpPoint, "id", "userId", "lng", "lat", "createdAt")
}