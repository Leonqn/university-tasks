module Auth.Model exposing (..)

import Http


type FieldError
    = Init
    | Email
    | Password


type alias Credentials =
    { email : Maybe String
    , password : Maybe String
    , remember : Bool
    }


type alias UserInfo =
    { email : String
    , token : String
    }


type alias Model =
    { credentials : Credentials
    , userInfo : Maybe UserInfo
    , error : Maybe Http.Error
    , loading : Maybe Bool
    }


init : Maybe UserInfo -> Model
init userInfo =
    Model (Credentials Nothing Nothing False) userInfo Nothing Nothing
