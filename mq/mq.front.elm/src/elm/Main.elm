module Main exposing (..)

import Navigation
import Routing exposing (Route)
import Model exposing (Model)
import View
import Messages
import Update
import Auth.Model
import Programs.Subs as Programs


main : Program (Maybe Auth.Model.UserInfo) Model Messages.Msg
main =
    Navigation.programWithFlags
        (Routing.router >> Messages.Route)
        { init = Model.init
        , update = Update.update
        , view = View.view
        , subscriptions = sub
        }


sub : Model -> Sub Messages.Msg
sub model =
    case model.route of
        Routing.Program id tasksPage ->
            Programs.getTasks id tasksPage
                |> Sub.map Messages.ProgramsMsg

        Routing.Programs _ Nothing ->
            Programs.getTasksStatus () |> Sub.map Messages.ProgramsMsg

        _ ->
            Sub.none
