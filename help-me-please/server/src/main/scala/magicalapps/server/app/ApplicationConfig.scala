package magicalapps.server.app

import com.typesafe.config.ConfigFactory
import java.io.File

object ApplicationConfig {

    val applicationConfig = ConfigFactory.parseFile(new File("conf/application.conf"))

    import applicationConfig._

    val port = getInt("app.port")

    val ip = getString("app.ip")
}