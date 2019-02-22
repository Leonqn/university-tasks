module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (Model)
import Routing exposing (Route(..))
import Auth.View as Auth
import Programs.Views.List as Programs
import Programs.Views.Details as Programs
import Messages exposing (Msg(..))
import Common.Maybe as Maybe
import Common.Utils as Utils


navItem : String -> String -> Bool -> Html msg
navItem link name isActive =
    a
        [ classList
            [ ( "nav-item", True )
            , ( "is-tab", True )
            , ( "is-active", isActive )
            ]
        , href link
        ]
        [ text name ]


menu : Model -> Html Msg
menu model =
    let
        isLoggedIn =
            Maybe.isJust model.authModel.userInfo

        isLoading =
            Utils.ifAnyTrue [ model.authModel.loading, model.programsModel.programs.fetching, model.programsModel.executionResults.fetching, model.programsModel.tasks.fetching ]

        isProgramsPage =
            case model.route of
                Programs _ _ ->
                    True

                Program _ _ ->
                    True

                _ ->
                    False

        isProgramsListPage =
            case model.route of
                Programs _ _ ->
                    True

                _ ->
                    False
    in
        nav [ class "nav has-shadow" ]
            [ div [ class "container is-fluid" ]
                [ div [ class "nav-left" ]
                    [ a [ class "nav-item", href "#" ] [ text "Mq" ]
                    , navItem "#" "Forms" False
                    , navItem (Routing.programs 1)
                        "Programs"
                        isProgramsPage
                    , navItem "#" "Tasks" False
                    , case model.route of
                        Programs page addToScope ->
                            div [ class "nav-item" ] [ Html.map ProgramsMsg (Programs.filterForm model.programsModel.filter page addToScope) ]

                        _ ->
                            div [] []
                    ]
                , div [ class "nav-right" ]
                    [ div [ class "nav-item" ]
                        [ div [ classList [ ( "loaderr", isLoading ) ] ] []
                        ]
                    , case model.route of
                        Programs _ _ ->
                            div [ class "nav-item" ] [ Html.map ProgramsMsg Programs.addProgramBtn ]

                        Program id _ ->
                            div [ class "nav-item" ] [ Html.map ProgramsMsg (Programs.runBtn id) ]

                        _ ->
                            div [] []
                    , div [ class "nav-item" ]
                        [ if isLoggedIn then
                            Html.map AuthMsg Auth.signOutLink
                          else
                            navItem Routing.signIn "Sign In" (not isLoggedIn)
                        ]
                    ]
                ]
            ]


panels : Model -> Html Msg
panels model =
    case model.route of
        SignIn ->
            div [ class "container" ] [ Html.map AuthMsg (Auth.signInForm model.authModel) ]

        Program id tasksPage ->
            -- authorizedView
            div [ class "container is-fluid" ] [ Html.map ProgramsMsg (Programs.details id tasksPage model.programsModel) ]

        -- model
        Programs page addToScope ->
            -- authorizedView
            div [ class "container is-fluid" ] [ Html.map ProgramsMsg (Programs.list page addToScope model.programsModel) ]

        -- model
        Root ->
            div [] []


view : Model -> Html Msg
view model =
    div []
        [ menu model
        , panels model
        ]
