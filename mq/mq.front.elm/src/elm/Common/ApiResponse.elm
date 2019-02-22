module Common.ApiResponse exposing (..)

import Http


type alias ApiResponse a =
    Maybe (Result Http.Error a)


fromMaybe : Maybe a -> ApiResponse a
fromMaybe x =
    case x of
        Just x ->
            Just (Ok x)

        _ ->
            Nothing


map2 :
    (a -> b -> value)
    -> ApiResponse a
    -> ApiResponse b
    -> ApiResponse value
map2 =
    Maybe.map2 << Result.map2


map : (a -> value) -> ApiResponse a -> ApiResponse value
map =
    Maybe.map << Result.map


andThen :
    (a -> ApiResponse b)
    -> ApiResponse a
    -> ApiResponse b
andThen f x =
    case x of
        Just (Ok x) ->
            f x

        Just (Err msg) ->
            Just (Err msg)

        Nothing ->
            Nothing


isOk : ApiResponse a -> Bool
isOk x =
    case x of
        Just (Ok _) ->
            True

        _ ->
            False

isNone : ApiResponse a -> Bool
isNone x =
    case x of
        Nothing ->
            True
        Just (Err err) ->
            False
        Just (Ok _) ->
            False
