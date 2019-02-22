module Common.Errors exposing (..)

import Resources exposing (..)
import Http exposing (Error(..))


classifyError : (Http.Response String -> String) -> Error -> String
classifyError classifier error =
    case error of
        BadUrl url ->
            badUrl url

        Timeout ->
            timeout

        NetworkError ->
            networkError

        BadPayload msg _ ->
            unexpectedPayload msg

        BadStatus response ->
            classifier response
