package magicalapps.server.database.entities

import java.sql.Timestamp
import org.squeryl.KeyedEntity

case class HelpPoint(id: String,
                     userId: String,
                     lng: Double,
                     lat: Double,
                     createdAt: Timestamp) extends KeyedEntity[String]