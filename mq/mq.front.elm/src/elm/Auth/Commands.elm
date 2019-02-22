module Auth.Commands exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Http
import Auth.Messages
import Auth.Model exposing (UserInfo)
import Common.Http as Http

signin : String -> String -> Cmd Auth.Messages.Msg
signin email password =
    Http.send Auth.Messages.OnToken (signinRequest email password)


signinRequest : String -> String -> Http.Request UserInfo
signinRequest email password =
    Http.request
        { body = encodeCredentials email password |> Http.jsonBody
        , expect = Http.expectJson (tokenDecoder email)
        , headers = [ ]
        , method = "POST"
        , timeout = Nothing
        , url = Http.makeUri "rpc/login" []
        , withCredentials = False
        }


tokenDecoder : String -> Decoder UserInfo
tokenDecoder email =
    Decode.map2 UserInfo
     (Decode.succeed email)
     (Decode.field "token" Decode.string)


encodeCredentials : String -> String -> Encode.Value
encodeCredentials email password =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "password", Encode.string password )
        ]
