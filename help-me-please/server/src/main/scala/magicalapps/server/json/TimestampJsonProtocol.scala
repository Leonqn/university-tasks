package magicalapps.server.json

import spray.json._
import java.sql.Timestamp
import org.joda.time.format.DateTimeFormat
import org.joda.time.DateTime

object TimestampJsonProtocol extends DefaultJsonProtocol {

    implicit val timestampJF = new RootJsonFormat[Timestamp] {

        override def write(obj: Timestamp) = {
            DateTimeFormat.mediumDateTime().print(new DateTime(obj.getTime)).toJson
        }

        override def read(json: JsValue) = ???
    }
}