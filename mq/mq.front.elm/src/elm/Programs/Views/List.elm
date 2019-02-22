module Programs.Views.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Programs.Model as Model exposing (Model, NewProgram)
import Html.Events exposing (onInput, onSubmit, onClick)
import Programs.Messages exposing (Msg(..))
import Common.Views.Paging as Paging
import Routing
import Common.Maybe as Maybe
import Programs.Model
import Ace
import List.Extra as List
import Dict
import Common.Utils as Utils
import Common.Views.ErrorView exposing (errorModal)
import Dict exposing (Dict)


list : Int -> Maybe Int -> Model -> Html Msg
list page addToScope { programs, filter, newProgram, showAddProgramModal, tasksStatus } =
    let
        programsList =
            programs.showing
                |> List.filterMap (\x -> Dict.get x programs.items)

        createProgramModalId =
            "createProgram"

        createProgramsUrl =
            case addToScope of
                Just x ->
                    Routing.addToScope x

                Nothing ->
                    Routing.programs
    in
        div [ class "programs-preview" ]
            [ div [ style [ ( "margin-top", "1rem" ), ( "margin-bottom", "1rem" ) ] ]
                [ Paging.paging page programs.count createProgramsUrl ]
            , programsGrid addToScope programsList programs.items tasksStatus.items
            , addProgramForm showAddProgramModal newProgram
            , errorModal (programs.error |> Maybe.map toString) CloseProgramsError
            ]


filterForm : String -> Int -> Maybe Int -> Html Msg
filterForm filter page addToScope =
    p [ class "has-icon control" ]
        [ input
            [ class "input"
            , type_ "text"
            , value filter
            , placeholder "Search"
            , onInput (GetPrograms 1)
            , onClick (Search page addToScope)
            ]
            []
        , span [ class "icon is-small" ]
            [ i [ attribute "aria-hidden" "true", class "fa fa-search" ]
                []
            ]
        ]


addProgramBtn : Html Msg
addProgramBtn =
    button [ class "button is-primary", onClick ToggleAddProgramModal ] [ text "Create program" ]


addProgramForm : Bool -> NewProgram -> Html Msg
addProgramForm isActive newProgram =
    div [ classList [ ( "modal", True ), ( "is-active", isActive ) ] ]
        [ div [ class "modal-background", onClick ToggleAddProgramModal ]
            []
        , div [ class "modal-card" ]
            [ header [ class "modal-card-head" ]
                [ p [ class "modal-card-title" ]
                    [ text "Create program" ]
                , button [ class "delete", onClick ToggleAddProgramModal ]
                    []
                ]
            , section [ class "modal-card-body" ]
                [ Html.form
                    [ class "control"
                    , novalidate True
                    , onSubmit CreateProgram
                    ]
                    [ p [ class "control" ]
                        [ input [ class "input", placeholder "Name", type_ "text", onInput SetName ] []
                        , textarea [ class "textarea", placeholder "Description", onInput SetDescription ] []
                        ]
                    ]
                ]
            , footer [ class "modal-card-foot" ]
                [ button
                    [ class "button is-primary"
                    , attribute "data-dismiss" "modal"
                    , disabled (not (Maybe.isJust newProgram.name))
                    , type_ "submit"
                    , onClick CreateProgram
                    ]
                    [ text "Add" ]
                ]
            ]
        ]


programsGrid : Maybe Int -> List Model.Program -> Dict Int Model.Program -> Dict Int Model.TasksStatus -> Html Msg
programsGrid addToScope programs allPrograms tasksStatuses =
    -- todo: do this better if possible
    let
        scopeBtns viewProgram =
            case addToScope of
                Just programId ->
                    case Dict.get programId allPrograms |> Maybe.map .scope of
                        Just scope ->
                            Just
                                (button
                                    [ class "button"
                                    , disabled (viewProgram.id == programId || (List.find ((==) viewProgram.id) scope |> Maybe.isJust))
                                    , onClick (AddToScope programId viewProgram)
                                    ]
                                    [ span
                                        [ class "icon" ]
                                        [ i [ class "fa fa-plus", attribute "aria-hidden" "true" ] []
                                        ]
                                    ]
                                )

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing
    in
        div []
            (List.greedyGroupsOf 3 programs
                |> List.map (\programs -> div [ class "columns" ] (List.map (programPreview scopeBtns tasksStatuses) programs))
            )


programPreview : (Model.Program -> Maybe (Html Msg)) -> Dict Int Model.TasksStatus -> Model.Program -> Html Msg
programPreview scopeBtns tasksStatus program  =
    let
        previewText =
            case program.description of
                Just x ->
                    text x

                Nothing ->
                    Ace.toHtml
                        [ Ace.value program.code
                        , Ace.readOnly True
                        , Ace.highlightActiveLine False
                        , Ace.showCursor False
                        , Ace.showGutter False
                        , Ace.mode "matlab"
                        ]
                        []
        taskStatus =
            Dict.get program.id tasksStatus
            |> Maybe.withDefault { executing = 0, inQueue = 0, completed = 0 }
    in
        div [ class "column is-one-third" ]
            [ div [ class "card" ]
                [ header [ class "card-header" ]
                    [ p [ class "card-header-title" ]
                        [ div
                            []
                            [ p [] [ text program.name ], p [] [ text <| Utils.formatDate program.createdAt ] ]
                        ]
                    , small [ class "card-header-icon" ]
                        [ case scopeBtns program of
                            Just btns ->
                                btns

                            Nothing ->
                                div [ class "control is-grouped is-disabled is-small" ]
                                    [ p [ class "control" ]
                                        [ div [ class "button" ]
                                            [ span
                                                [ class "icon" ]
                                                [ i [ class "fa fa-spinner", attribute "aria-hidden" "true" ] []
                                                ]
                                            , span [] [ text (toString taskStatus.executing) ]
                                            ]
                                        ]
                                    , p [ class "control" ]
                                        [ div [ class "button" ]
                                            [ span
                                                [ class "icon" ]
                                                [ i [ class "fa fa-circle-o-notch", attribute "aria-hidden" "true" ] []
                                                ]
                                            , span [] [ text (toString taskStatus.inQueue) ]
                                            ]
                                        ]
                                    , p [ class "control" ]
                                        [ div [ class "button" ]
                                            [ span
                                                [ class "icon" ]
                                                [ i [ class "fa fa-check", attribute "aria-hidden" "true" ] []
                                                ]
                                            , span [] [ text (toString taskStatus.completed) ]
                                            ]
                                        ]
                                    ]
                        ]
                    ]
                , div [ class "card-content" ]
                    [ div [ class "content" ]
                        [ div [ style [ ( "height", "155px" ) ] ]
                            [ previewText ]
                        ]
                    ]
                , footer [ class "card-footer" ]
                    [ a [ class "card-footer-item", href <| Routing.program program.id 1 ] [ text "Edit" ]
                    , a [ class "card-footer-item" ] [ text "Delete" ]
                    ]
                ]
            ]
