package magicalapps.server.utils

import java.util.UUID

trait UUIDHelper {

    def newUUID = UUID.randomUUID.toString
}

object UUIDHelper extends UUIDHelper