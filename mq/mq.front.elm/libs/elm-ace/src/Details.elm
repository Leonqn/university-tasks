module Programs.Views.Details exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Programs.Model as Model exposing (Model, ExecutionResult, Task)
import Programs.Messages exposing (..)
import Ace
import Routing
import Date.Extra.Format as Date
import Dict
import List.Extra as List


details : Int -> Model -> Html Msg
details id { programs, executionResults, tasks } =
    case Dict.get id programs of
        Just program ->
            div []
                [ div []
                    [ h2 [ class "d-inline-block" ] [ text program.name ]
                    , h6 [ style [ ( "margin-bottom", "1rem" ) ] ] [ text (Date.isoStringNoOffset program.createdAt) ]
                    , h5 [] [ text <| Maybe.withDefault "" program.description ]
                    ]
                , table [ style [ ( "width", "100%" ), ( "table-layout", "fixed" ) ] ]
                    [ colgroup []
                        [ col [ style [ ( "width", "70%" ) ] ] []
                        , col [ style [ ( "width", "30%" ) ] ] []
                        ]
                    , tbody []
                        [ tr []
                            [ td [ style [ ( "vertical-align", "top" ) ] ]
                                [ scope program (List.filterMap (\x -> Dict.get x programs) program.scope)
                                , editor program.id program.code
                                ]
                            , td [ style [ ( "vertical-align", "top" ) ] ]
                                [ runBtn program.id
                                , resultsList
                                    (List.filterMap (\x -> Dict.get x tasks) program.tasks
                                        |> List.map (\x -> ( x, Dict.values executionResults |> List.find (.task >> (==) x.id) ))
                                    )
                                ]
                            ]
                        ]
                    ]
                ]

        Nothing ->
            div [] []


editor : Int -> String -> Html Msg
editor programId code =
    Ace.toHtml
        [ Ace.value code
        , Ace.readOnly False
        , Ace.onSourceChange (UpdateCode programId)
        ]
        []


runBtn : Int -> Html Msg
runBtn programId =
    button [ class "btn btn-secondary", onClick (RunProgram programId) ] [ text "Run" ]


scope : Model.Program -> List Model.Program -> Html Msg
scope program scope =
    div []
        [ scopeList program.id scope
        , a [ class "btn btn-secondary add-to-scope", href (Routing.addToScope 1 program.id) ]
            [ i [ class "fa fa-plus", attribute "aria-hidden" "true" ] [] ]
        ]


resultsList : List ( Task, Maybe ExecutionResult ) -> Html Msg
resultsList executionResults =
    ul [ class "list-group" ]
        (List.map
            resultItem
            executionResults
        )


resultItem : ( Task, Maybe ExecutionResult ) -> Html Msg
resultItem ( task, executionResult ) =
    li [ class "list-group-item" ]
        [ div []
            [ table [ style [ ( "width", "100%" ), ( "table-layout", "fixed" ) ] ]
                [ tbody []
                    [ tr []
                        [ td [] [ text "Created at" ]
                        , td []
                            [ text (Date.isoStringNoOffset task.createdAt) ]
                        , td [ class "float-xs-right" ]
                            [ case executionResult of
                                Just executionResult ->
                                    case executionResult.status of
                                        Model.Ok ->
                                            i [ class "fa fa-check", attribute "aria-hidden" "true" ] []

                                        Model.Failed ->
                                            i [ class "fa fa-times", attribute "aria-hidden" "true" ] []

                                Nothing ->
                                    case task.status of
                                        Model.Executing ->
                                            i [ class "fa fa-spinner", attribute "aria-hidden" "true" ] []

                                        Model.InQueue ->
                                            i [ class "fa fa-circle-o-notch", attribute "aria-hidden" "true" ] []

                                        Model.Completed ->
                                            i [] []
                            ]
                        ]
                    , tr []
                        [ td [] [ text "Started at" ]
                        , td []
                            [ text
                                (case task.startedAt of
                                    Just startedAt ->
                                        (Date.isoStringNoOffset startedAt)

                                    Nothing ->
                                        "Not yed completed"
                                )
                            ]
                        ]
                    , tr []
                        [ td [] [ text "Completed at" ]
                        , td []
                            [ text
                                (case task.completedAt of
                                    Just completedAt ->
                                        (Date.isoStringNoOffset completedAt)

                                    Nothing ->
                                        "Not yet completed"
                                )
                            ]
                        , td [ class "float-xs-right" ]
                            [ case executionResult of
                                Just executionResult ->
                                    case executionResult.content of
                                        Just content ->
                                            button [ class "btn btn-sm btn-secondary float-xs-right", onClick (DownloadZip content) ] [ text "Download zip" ]

                                        Nothing ->
                                            button [ class "btn btn-sm btn-secondary float-xs-right", onClick (GetContent executionResult.id) ] [ text "Get content" ]

                                Nothing ->
                                    div [] []
                            ]
                        ]
                    ]
                ]
            ]
        ]


scopeList : Int -> List Model.Program -> Html Msg
scopeList currentProgramId scope =
    ul [ class "list-group d-inline-block" ]
        (List.map (scopeItem currentProgramId) scope)


scopeItem : Int -> Model.Program -> Html Msg
scopeItem currentProgramId program =
    li
        [ class "d-inline-block btn btn-secondary scope-tab" ]
        [ div [ class "d-inline-block" ]
            [ a [ class "d-inline-block", href (Routing.program program.id) ] [ text program.name ] ]
        , i [ class "fa fa-times remove-scope", attribute "aria-hidden" "true", onClick (RemoveFromScope currentProgramId program.id) ] []
        ]
