module Common.Validate exposing (..)

withMaybe : (a -> List b) -> Maybe a -> List b
withMaybe validate x =
    case x of
        Just x ->
            validate x
        Nothing ->
            []
