module Update exposing (..)

import Auth.Update as Auth
import Auth.Messages as Auth
import Programs.Update as Programs
import Programs.Messages as Programs
import Programs.Commands as Programs
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Route(..))
import Navigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Messages.Route route ->
            case ( route, model.authModel.userInfo ) of
                ( SignIn, Just _ ) ->
                    model ! [ Navigation.modifyUrl Routing.root ]

                ( SignIn, Nothing ) ->
                    { model | route = route } ! []

                ( _, Nothing ) ->
                    { model | hasBackUrl = True } ! [ Navigation.newUrl Routing.signIn ]

                --todo maybe remove this and do something else?
                ( Programs page addToScope, Just userInfo ) ->
                    { model | route = route }
                        ! [ Cmd.map ProgramsMsg (Programs.getPrograms userInfo.token page model.programsModel.filter)
                          , case addToScope of
                                Just x ->
                                    Cmd.map ProgramsMsg (Programs.getProgram userInfo.token x)

                                Nothing ->
                                    Cmd.none
                          ]

                ( Program id tasksPage, Just userInfo ) ->
                    update
                        (ProgramsMsg (Programs.GetProgram id tasksPage))
                        { model | route = route }

                _ ->
                    { model | route = route } ! []

        --todo do better
        AuthMsg msg ->
            let
                ( authModel, cmd ) =
                    Auth.update msg model.authModel
            in
                case msg of
                    Auth.OnToken (Ok _) ->
                        { model | authModel = authModel }
                            ! [ Cmd.map AuthMsg cmd
                              , if model.hasBackUrl then
                                    Navigation.back 1
                                else
                                    Navigation.modifyUrl Routing.root
                              ]

                    Auth.SignOut ->
                        { model | authModel = authModel, hasBackUrl = True }
                            ! [ Cmd.map AuthMsg cmd, Navigation.newUrl Routing.signIn ]

                    _ ->
                        { model | authModel = authModel } ! [ Cmd.map AuthMsg cmd ]

        ProgramsMsg msg ->
            case model.authModel.userInfo of
                Just userInfo ->
                    let
                        ( programsModel, cmd ) =
                            Programs.update userInfo.token msg model.programsModel
                    in
                        ( { model | programsModel = programsModel }, Cmd.map ProgramsMsg cmd )

                _ ->
                    model ! []
