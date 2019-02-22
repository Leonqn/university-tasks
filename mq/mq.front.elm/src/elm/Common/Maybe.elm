module Common.Maybe exposing (..)


isJust : Maybe a -> Bool
isJust x =
    case x of
        Just _ ->
            True

        Nothing ->
            False
