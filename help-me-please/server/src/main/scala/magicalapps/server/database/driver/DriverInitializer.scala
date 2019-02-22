package magicalapps.server.database.driver

import org.squeryl.{Session, SessionFactory}
import org.squeryl.adapters.PostgreSqlAdapter
import magicalapps.server.database.config.DatabaseConfig

object DriverInitializer {

    def initialize() {
        Class.forName("org.postgresql.Driver")
        SessionFactory.concreteFactory = Some(() => Session.create(connection, new PostgreSqlAdapter))
    }

    private def connection = java.sql.DriverManager.getConnection(
        DatabaseConfig.url,
        DatabaseConfig.user,
        DatabaseConfig.password
    )
}