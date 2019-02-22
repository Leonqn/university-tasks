port module Port exposing (..)

import Auth.Model exposing (UserInfo)

port store : UserInfo -> Cmd msg

port clear : () -> Cmd msg

port downloadZip : String -> Cmd msg
