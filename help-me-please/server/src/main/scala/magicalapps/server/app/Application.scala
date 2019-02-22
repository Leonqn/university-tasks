package magicalapps.server.app

import akka.actor.ActorSystem
import magicalapps.server.database.driver.DriverInitializer
import spray.routing.SimpleRoutingApp
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.future
import magicalapps.server.routes.Routes

object Application extends App with SimpleRoutingApp {

    def log = actorSystem.log

    DriverInitializer.initialize()

    private implicit val actorSystem = ActorSystem("actors", ApplicationConfig.applicationConfig)

    future {
        startServer(interface = ApplicationConfig.ip, port = ApplicationConfig.port)(Routes.$)
    }

    readLine()

    actorSystem.shutdown()
}