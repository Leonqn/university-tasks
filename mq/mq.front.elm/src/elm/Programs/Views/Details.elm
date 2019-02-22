module Programs.Views.Details exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Programs.Model as Model exposing (Model, ExecutionResult, Task)
import Programs.Messages exposing (..)
import Ace
import Routing
import Dict
import List.Extra as List
import Common.Views.Paging as Paging
import Common.Views.ErrorView exposing (errorModal)

details : Int -> Int -> Model -> Html Msg
details id tasksPage { programs, executionResults, tasks } =
    case Dict.get id programs.items of
        Just program ->
            div [ class "programs-details" ]
                [ div []
                    [ h1 [ class "title" ] [ text program.name ]
                    , h2 [ class "subtitle" ] [ text <| Maybe.withDefault "" program.description ]
                    ]
                , div [ class "columns" ]
                    [ div [ class "column" ]
                        [ scope program (List.filterMap (\x -> Dict.get x programs.items) program.scope)
                        , editor program.id program.code
                        ]
                    , div [ class "column is-narrow" ]
                        [ div [ style [ ( "padding", "0.75rem" ), ( "margin-top", "7px" ) ] ] [ Paging.paging tasksPage (Basics.max 1 tasks.count) <| Routing.program id ]
                        , div [ style [ ( "margin-top", "3px" ) ] ]
                            [ resultsList
                                (List.filterMap (\x -> Dict.get x tasks.items) program.tasks
                                    |> List.map (\x -> ( x, Dict.values executionResults.items |> List.find (.task >> (==) x.id) ))
                                )
                            ]
                        ]
                    ]
                    , errorModal (programs.error |> Maybe.map toString) CloseProgramsError
                    , errorModal (executionResults.error |> Maybe.map toString) CloseExecutionResultsError
                    , errorModal (tasks.error |> Maybe.map toString) CloseTasksError
                ]

        Nothing ->
            div [] []


editor : Int -> String -> Html Msg
editor programId code =
    Ace.toHtml
        [ Ace.value code
        , Ace.readOnly False
        , Ace.onSourceChange (UpdateCode programId)
        , Ace.mode "matlab"
        ]
        []


runBtn : Int -> Html Msg
runBtn programId =
    button [ class "button is-primary", onClick (RunProgram programId) ] [ text "Run" ]


scope : Model.Program -> List Model.Program -> Html Msg
scope program scope =
    div []
        [ scopeList program.id scope
        ]


addToScopeBtn : Int -> Html Msg
addToScopeBtn programId =
    a
        [ class "button is-primary is-narrow"
        , href (Routing.addToScope programId 1)
        ]
        [ span
            [ class "icon" ]
            [ i [ class "fa fa-plus", attribute "aria-hidden" "true" ] []
            ]
        ]


removeFromScopeBtn : Int -> Model.Program -> Html Msg
removeFromScopeBtn currentProgramId program =
    a
        [ class "is-small"
        , onClick (RemoveFromScope currentProgramId program.id)
        , style [ ( "margin-left", "0.5rem" ) ]
        ]
        [ span
            [ class "icon" ]
            [ i [ class "fa fa-times", attribute "aria-hidden" "true" ] []
            ]
        ]


resultsList : List ( Task, Maybe ExecutionResult ) -> Html Msg
resultsList executionResults =
    div []
        (List.map
            resultItem
            executionResults
        )


resultItem : ( Task, Maybe ExecutionResult ) -> Html Msg
resultItem ( task, executionResult ) =
    div [ class "tile" ]
        [ div [ class "card", style [ ( "width", "100%" ) ] ]
            [ div [ class "card-header" ]
                [ p [ class "card-header-title" ] [ text ("# " ++ (toString task.id)) ]
                , case executionResult of
                    Just executionResult ->
                        a [ class "card-header-icon", onClick (GetContent executionResult.id) ]
                            [ span [ class "icon" ]
                                [ i [ class "fa fa-download" ] [] ]
                            ]

                    Nothing ->
                        case task.status of
                            Model.Executing ->
                                a [ class "card-header-icon is-disabled" ]
                                    [ span [ class "icon" ]
                                        [ i [ class "fa fa-spinner" ] [] ]
                                    ]

                            Model.InQueue ->
                                a [ class "card-header-icon is-disabled" ]
                                    [ span [ class "icon" ]
                                        [ i [ class "fa fa-circle-o-notch" ] [] ]
                                    ]

                            Model.Completed ->
                                a [ class "card-header-icon is-disabled" ]
                                    [ span [ class "icon" ]
                                        [ i [ class "fa fa-times" ] [] ]
                                    ]
                ]
            ]
        ]


scopeList : Int -> List Model.Program -> Html Msg
scopeList currentProgramId scope =
    div
        [ class "columns"
        , style [ ( "margin-bottom", "1px" ), ( "margin-top", "5px" ) ]
        ]
        [ div [ class "column is-narrow" ]
            [ addToScopeBtn currentProgramId ]
        , div [ class "column is-narrow" ]
            [ div
                [ class "columns" ]
                (List.map (scopeItem currentProgramId) scope)
            ]
        ]


scopeItem : Int -> Model.Program -> Html Msg
scopeItem currentProgramId program =
    div [ class "column is-gapless is-narrow scope-item" ]
        [ div [ class "scope-tab" ]
            [ div [ class "button" ]
                [ a [ href (Routing.program program.id 1) ] [ text program.name ]
                , removeFromScopeBtn currentProgramId program
                ]
            ]
        ]
