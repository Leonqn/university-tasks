package magicalapps.server.database.schemas

import org.squeryl.Schema
import magicalapps.server.database.entities.HelpPoint

trait HelpPointsSchema extends Schema {

    val helpPointTable = table[HelpPoint]
}