package magicalapps.server.database.schemas

import magicalapps.server.database.entities.User
import org.squeryl.Schema

trait UserSchema extends Schema {

    protected val userTable = table[User]
}