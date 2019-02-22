package magicalapps.server.database.services

import org.squeryl.PrimitiveTypeMode._
import magicalapps.server.database.schemas.HelpPointsSchema
import magicalapps.server.database.entities.HelpPoint
import magicalapps.server.utils.{DateHelper, UUIDHelper}

object HelpPointService extends HelpPointsSchema with UUIDHelper with DateHelper {

    def add(userId: String, lng: Double, lat: Double) = transaction {
        helpPointTable.insert(
            HelpPoint(newUUID, userId, lng, lat, now)
        )
    }

    def selectFromSquare(lng: Double, lat: Double, side: Double) = transaction {
        from (helpPointTable)( hp =>
            where (
                (hp.lat between (lat - side, lat + side)) and
                (hp.lng between (lng - side, lng + side))
            ) select hp
        ).toList
    }
}