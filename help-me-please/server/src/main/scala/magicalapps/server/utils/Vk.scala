package magicalapps.server.utils

import _root_.spray.client.pipelining._
import _root_.spray.http.{HttpResponse, HttpRequest}


import akka.actor.ActorSystem
import scala.concurrent.Future
import scala.util.parsing.json.JSON
import scala.Some

object Vk {

  implicit val system = ActorSystem()
  import system.dispatcher // execution context for futures

  val pipeline: HttpRequest => Future[HttpResponse] = sendReceive

  def getUserId(token: String) = {
      val response = pipeline(Get(s"https://api.vk.com/method/users.get?access_token=$token&v=5.21")).map(_.entity.asString)
      JSON.parseFull(response.value.get.get) match {
          case Some(m: Array[Map[String, String]]) => m(0)("id")
    }
  }
}
