package magicalapps.server.database.config

import com.typesafe.config.ConfigFactory
import java.io.File

object DatabaseConfig {

    val databaseConfig = ConfigFactory.parseFile(new File("conf/db.conf"))

    import databaseConfig._

    val user = getString("app.db.user")

    val password = getString("app.db.password")

    val url = getString("app.db.url")
}