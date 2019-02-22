module Programs.Decoders exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode
import Programs.Model as Model exposing (ExecutionStatus(..), TaskStatus(..))
import Dict
import List.Extra as List
import Common.Decode as Decode


contentDecoder : Decoder String
contentDecoder =
    Decode.at [ "content" ] Decode.string


programsDecoder : Decoder (List Model.Program)
programsDecoder =
    Decode.list programDecoder


executionResultsDecoder : Decoder (List Model.ExecutionResult)
executionResultsDecoder =
    Decode.list executionResultDecoder


tasksDecoder : Decoder (List Model.Task)
tasksDecoder =
    Decode.list taskDecoder


executionResultDecoder : Decoder Model.ExecutionResult
executionResultDecoder =
    Decode.decode Model.ExecutionResult
        |> Decode.required "id" Decode.int
        |> Decode.required "status" executionStatusDecoder
        |> Decode.required "task" Decode.int
        |> Decode.required "program" Decode.int
        |> Decode.optional "content" (Decode.nullable Decode.string) Nothing


taskDecoder : Decoder Model.Task
taskDecoder =
    Decode.decode Model.Task
        |> Decode.required "id" Decode.int
        |> Decode.required "status" taskStatusDecoder
        |> Decode.required "created_at" Decode.date
        |> Decode.optional "started_at" (Decode.nullable Decode.date) Nothing
        |> Decode.optional "completed_at" (Decode.nullable Decode.date) Nothing
        |> Decode.required "program" Decode.int


tasksStatusDecoder : Decoder (Dict.Dict Int Model.TasksStatus)
tasksStatusDecoder =
    let
        tasksStatus =
            Decode.decode (\status count program -> (status, count, program))
            |> Decode.required "status" Decode.string
            |> Decode.required "count" Decode.int
            |> Decode.required "program" Decode.int

        first (x, _, _) = x

        second (_, x, _) = x

        find status =
            List.find (first >> ((==) status))
            >> Maybe.map second
            >> Maybe.withDefault 0

        groupByProgram =
            List.groupWhile (\(_, _, program) (_, _, program2) -> program == program2 )
            >> List.filterMap (\x ->
                case x of
                    [] ->
                        Nothing
                    (_, _, program)::_ as list ->
                        Just (program,
                                { executing = find "executing" list
                                , inQueue = find "free" list
                                , completed = find "completed" list
                                }))
            >> Dict.fromList
    in
        Decode.list tasksStatus
        |> Decode.map groupByProgram

programDecoder : Decoder Model.Program
programDecoder =
    Decode.decode Model.Program
        |> Decode.required "id" Decode.int
        |> Decode.required "name" Decode.string
        |> Decode.required "description"
            ((Decode.nullable Decode.string)
                |> Decode.map
                    (Maybe.andThen
                        (\x ->
                            if x == "" then
                                Nothing
                            else
                                Just x
                        )
                    )
            )
        |> Decode.required "author" Decode.string
        |> Decode.required "code" Decode.string
        |> Decode.required "created_at" Decode.date
        |> Decode.optional "scope" (Decode.list (Decode.at [ "scope_program", "id" ] Decode.int)) []
        |> Decode.optional "execution_results" (Decode.list (Decode.at [ "id" ] Decode.int)) []
        |> Decode.optional "tasks" (Decode.list (Decode.at [ "id" ] Decode.int)) []


sizeFromHeadersDecoder : Dict.Dict String String -> Result String Int
sizeFromHeadersDecoder =
    Dict.get "Content-Range"
        >> Maybe.map (String.split "/")
        >> Maybe.andThen List.last
        >> Result.fromMaybe "There is no range"
        >> Result.andThen String.toInt


executionStatusDecoder : Decoder ExecutionStatus
executionStatusDecoder =
    Decode.string
        |> Decode.map
            (\x ->
                case x of
                    "ok" ->
                        Model.Ok

                    _ ->
                        Failed
            )


taskStatusDecoder : Decoder TaskStatus
taskStatusDecoder =
    Decode.string
        |> Decode.map
            (\x ->
                case x of
                    "completed" ->
                        Completed

                    "executing" ->
                        Executing

                    _ ->
                        InQueue
            )
