package magicalapps.server.database.entities

import org.squeryl.KeyedEntity
import java.sql.Timestamp

case class User(id: String, lastHostAddress: String, createdAt: Timestamp) extends KeyedEntity[String]