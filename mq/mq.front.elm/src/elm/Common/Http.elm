module Common.Http exposing (..)

import Http
import Common.Utils as Utils
import Json.Decode as Decode
import Dict exposing (Dict)


type RequestStatus
    = Sent
    | GotResponse


exepctJsonWithHeaders : (Dict String String -> Result String b) -> Decode.Decoder a -> Http.Expect ( b, a )
exepctJsonWithHeaders headersDecoder bodyDecoder =
    Http.expectStringResponse
        (\response ->
            Result.map2
                (,)
                (headersDecoder response.headers)
                (Decode.decodeString bodyDecoder response.body)
        )


expectUnit : Http.Expect ()
expectUnit =
    Http.expectStringResponse (\x -> Ok ())


makeUri : String -> List ( a, b ) -> String
makeUri path queryParams =
    let
        queryString =
            List.map (\( k, v ) -> (Utils.toStr k) ++ "=" ++ Utils.toStr (v)) queryParams
                |> String.join "&"
    in
        "http://localhost:3322/" ++ path ++ "?" ++ queryString


acceptJsonHeader : Http.Header
acceptJsonHeader =
    Http.header "Accept" "application/json"


authHeader : String -> Http.Header
authHeader token =
    Http.header "Authorization" ("Bearer " ++ token)


pageHeader : Int -> Http.Header
pageHeader page =
    Http.header "range" (Utils.toStr ((page - 1) * 21) ++ "-" ++ Utils.toStr (20 * page))


type Prefer
    = Representation
    | Singular


preferHeader : Prefer -> Http.Header
preferHeader prefer =
    case prefer of
        Representation ->
            Http.header "Prefer" "return=representation"

        Singular ->
            Http.header "Prefer" "plurality=singular"
