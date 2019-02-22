package magicalapps.server.utils

import java.sql.Timestamp
import org.joda.time.DateTime

trait DateHelper {

    implicit class SQLWrapper(dateTime: DateTime) {

        implicit def toSQL = dateTimeToSQL(dateTime)
    }

    implicit def dateTimeToSQL(dateTime: DateTime) = new Timestamp(dateTime.toDate.getTime)

    def now = DateTime.now
}

object DateHelper extends DateHelper