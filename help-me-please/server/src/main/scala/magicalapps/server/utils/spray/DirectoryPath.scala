package magicalapps.server.utils.spray

import spray.routing.{Route, Directive0}
import shapeless.HNil
import spray.http.StatusCodes
import magicalapps.server.app.Application._

trait DirectoryPath {

    def dir(segment: String) = new Directive0 {

        def happly(f: HNil => Route) = pathPrefix(segment ~ PathEnd) {
            redirect("/" + segment + "/", StatusCodes.MovedPermanently)
        } ~
        pathPrefix(segment).happly(f)
    }
}

object DirectoryPath extends DirectoryPath