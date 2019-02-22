module Programs.Subs exposing (..)

import Programs.Messages exposing (Msg(..))
import Time exposing (..)


getTasks : Int -> Int -> Sub Msg
getTasks programId page =
    Time.every (Time.second * 5) (\_ -> GetTasks programId page)

getTasksStatus : () -> Sub Msg
getTasksStatus () =
    Time.every (Time.second * 5) (\_ -> GetTasksStatus)
