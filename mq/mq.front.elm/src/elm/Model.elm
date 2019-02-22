module Model exposing (..)

import Routing exposing (Route(..))
import Auth.Model
import Navigation exposing (Location)
import Messages exposing (Msg(..))
import Programs.Model


type alias Model =
    { route : Route
    , authModel : Auth.Model.Model
    , programsModel : Programs.Model.Model
    , errorMsg : String
    , hasBackUrl : Bool
    }


init : Maybe Auth.Model.UserInfo -> Location -> ( Model, Cmd Msg )
init userInfo location =
    Model
        Root
        (Auth.Model.init userInfo)
        (Programs.Model.init)
        ""
        False
        ! [ Navigation.modifyUrl location.hash ]
