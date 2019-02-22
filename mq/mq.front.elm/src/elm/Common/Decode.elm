module Common.Decode exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Date


date : Decoder Date.Date
date =
    Decode.string
        |> Decode.andThen
            (\val ->
                case Date.fromString val of
                    Err err ->
                        Decode.fail err

                    Result.Ok date ->
                        Decode.succeed date
            )
