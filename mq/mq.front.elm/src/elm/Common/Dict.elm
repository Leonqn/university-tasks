module Common.Dict exposing (..)

import Dict exposing (Dict)


ofList : (a -> comparable) -> List a -> Dict comparable a
ofList getKey list =
    Dict.fromList (List.map (\x -> ( getKey x, x )) list)


updateIfPresent
    : comparable
    -> (b -> b)
    -> Dict comparable b
    -> Dict comparable b
updateIfPresent id update =
    Dict.update id (Maybe.map update)
