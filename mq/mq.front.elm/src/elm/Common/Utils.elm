module Common.Utils exposing (..)

import Time exposing (Time)
import Task
import Process
import Date

delay : Time -> msg -> Cmd msg
delay time msg =
  Process.sleep time
  |> Task.andThen (always <| Task.succeed msg)
  |> Task.perform identity

delay500 : msg -> Cmd msg
delay500 =
    delay 500


ifAnyTrue : List (Maybe Bool) -> Bool
ifAnyTrue =
    List.foldl (\x acc -> acc || Maybe.withDefault False x) False

toStr : a -> String
toStr v =
  let
    str = toString v
  in
    if String.left 1 str == "\"" then
      String.dropRight 1 (String.dropLeft 1 str)
    else
      str

formatDate : Date.Date -> String
formatDate date =
    (toString (Date.hour date)) ++ ":" ++ (toString (Date.minute date)) ++ " - " ++ (toString (Date.day date)) ++ " " ++ (toString (Date.month date)) ++ " " ++ (toString (Date.year date))
