module Auth.Messages exposing (..)

import Http
import Auth.Model exposing (UserInfo)

type Msg
    = SetEmail String
    | SetPassword String
    | ToggleRemember
    | OnToken (Result Http.Error UserInfo)
    | SignIn
    | SignOut
    | ToggleLoading
