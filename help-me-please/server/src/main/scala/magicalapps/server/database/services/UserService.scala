package magicalapps.server.database.services

import org.squeryl.PrimitiveTypeMode._
import magicalapps.server.database.entities.User
import magicalapps.server.utils.{Vk, UUIDHelper, DateHelper}
import spray.http.RemoteAddress
import magicalapps.server.database.schemas.UserSchema

object UserService extends UserSchema with DateHelper with UUIDHelper {

    def register(token: String)(implicit ip: RemoteAddress) = ip.toOption.map { addr =>
        transaction {
            val id = Vk.getUserId(token)
            userTable.lookup(id).map { user =>
                val updated = user.copy(lastHostAddress = addr.getHostAddress)
                userTable.update(updated)
                updated
            }.getOrElse {
                val user = User(id, addr.getHostAddress, now)
                userTable.insert(user)
                user
            }
            // TODO: userTable.insertOrUpdate(user)
        }
    }
}