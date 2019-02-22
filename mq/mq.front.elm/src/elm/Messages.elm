module Messages exposing (..)

import Auth.Messages
import Programs.Messages
import Routing


type Msg
    = AuthMsg Auth.Messages.Msg
    | ProgramsMsg Programs.Messages.Msg
    | Route Routing.Route
