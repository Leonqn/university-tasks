module Programs.Commands exposing (..)

import Programs.Encoders as Encode
import Programs.Decoders as Decode
import Programs.Messages as Messages
import Programs.Model exposing (TaskStatus(..))
import Common.Http as Http exposing (Prefer(..))
import Http exposing (Response)


createProgram : String -> String -> String -> Cmd Messages.Msg
createProgram token name description =
    Http.request
        { body = Encode.newProgram name description |> Http.jsonBody
        , expect = Http.expectJson Decode.programDecoder
        , headers = [ Http.acceptJsonHeader, Http.authHeader token, Http.preferHeader Representation ]
        , method = "POST"
        , timeout = Nothing
        , url = Http.makeUri "programs" []
        , withCredentials = False
        }
        |> Http.send Messages.OnProgramCreated


getProgram : String -> Int -> Cmd Messages.Msg
getProgram token id =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson Decode.programDecoder
        , headers = [ Http.acceptJsonHeader, Http.authHeader token, Http.preferHeader Singular ]
        , method = "GET"
        , timeout = Nothing
        , url =
            Http.makeUri
                "programs"
                [ ( "id", "eq." ++ (toString id) )
                , ( "select", "*,scope{scope_program{*}}" )
                ]
        , withCredentials = False
        }
        |> Http.send Messages.OnProgram


getPrograms : String -> Int -> String -> Cmd Messages.Msg
getPrograms token page filter =
    let
        fts =
            if filter == "" then
                []
            else
                [ ( "fts", "@@." ++ filter ++ ":*" ) ]
    in
        Http.request
            { body = Http.emptyBody
            , expect = Http.exepctJsonWithHeaders Decode.sizeFromHeadersDecoder Decode.programsDecoder
            , headers = [ Http.acceptJsonHeader, Http.authHeader token, Http.pageHeader page ]
            , method = "GET"
            , timeout = Nothing
            , url =
                Http.makeUri
                    "programs"
                    ([ ( "order", "id.desc" )
                     , ( "select", "*,scope{scope_program{*}}" )
                     ]
                        ++ fts
                    )
            , withCredentials = False
            }
            |> Http.send Messages.OnProgramsWithSize


runProgram : String -> Int -> Cmd Messages.Msg
runProgram token id =
    Http.request
        { body = Encode.runProgram id |> Http.jsonBody
        , expect = Http.expectJson Decode.taskDecoder
        , headers = [ Http.acceptJsonHeader, Http.authHeader token, Http.preferHeader Representation ]
        , method = "POST"
        , timeout = Nothing
        , url = Http.makeUri "tasks" []
        , withCredentials = False
        }
        |> Http.send Messages.OnProgramRunned


getProgramsByIds : String -> List Int -> Cmd Messages.Msg
getProgramsByIds token ids =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson Decode.programsDecoder
        , headers = [ Http.acceptJsonHeader, Http.authHeader token ]
        , method = "GET"
        , timeout = Nothing
        , url =
            Http.makeUri
                "programs"
                [ ( "id", "in." ++ (String.join "," (List.map toString ids)) )
                , ( "select", "*,scope{scope_program{*}}" )
                ]
        , withCredentials = False
        }
        |> Http.send Messages.OnPrograms


addToScope : String -> Int -> Int -> Cmd Messages.Msg
addToScope token currentProgram toAddProgram =
    Http.request
        { body = Encode.addToScope currentProgram toAddProgram |> Http.jsonBody
        , expect = Http.expectUnit
        , headers = [ Http.authHeader token ]
        , method = "POST"
        , timeout = Nothing
        , url = Http.makeUri "scope" []
        , withCredentials = False
        }
        |> Http.send (Messages.OnAddToScope currentProgram toAddProgram)


removeFromScope : String -> Int -> Int -> Cmd Messages.Msg
removeFromScope token currentProgram toRemoveProgram =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectUnit
        , headers = [ Http.authHeader token ]
        , method = "DELETE"
        , timeout = Nothing
        , url =
            Http.makeUri
                "scope"
                [ ( "program", "eq." ++ (toString currentProgram) )
                , ( "scope_program", "eq." ++ (toString toRemoveProgram) )
                ]
        , withCredentials = False
        }
        |> Http.send (Messages.OnRemoveFromScope currentProgram toRemoveProgram)


updateCode : String -> Int -> String -> Cmd Messages.Msg
updateCode token id code =
    Http.request
        { body = Encode.code code |> Http.jsonBody
        , expect = Http.expectUnit
        , headers = [ Http.authHeader token ]
        , method = "PATCH"
        , timeout = Nothing
        , url =
            Http.makeUri
                "programs"
                [ ( "id", "eq." ++ (toString id) )
                ]
        , withCredentials = False
        }
        |> Http.send Messages.OnCodeUpdated


getExecutionResultsByTaskIds : String -> List Int -> Cmd Messages.Msg
getExecutionResultsByTaskIds token ids =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson Decode.executionResultsDecoder
        , headers = [ Http.authHeader token ]
        , method = "GET"
        , timeout = Nothing
        , url =
            Http.makeUri "execution_results"
                [ ( "task.id", "in." ++ (String.join "," (List.map toString ids)) )
                , ( "select", "id,task,program,status,args" )
                ]
        , withCredentials = False
        }
        |> Http.send Messages.OnExecutionResults


getTasks : String -> Maybe Int -> Int -> Cmd Messages.Msg
getTasks token programId page =
    Http.request
        { body = Http.emptyBody
        , expect = Http.exepctJsonWithHeaders Decode.sizeFromHeadersDecoder Decode.tasksDecoder
        , headers = [ Http.acceptJsonHeader, Http.authHeader token, Http.pageHeader page ]
        , method = "GET"
        , timeout = Nothing
        , url =
            Http.makeUri "tasks"
                (Maybe.withDefault
                    []
                    (Maybe.map (\x -> [ ( "program", "eq." ++ (toString x) ), ( "order", "id.desc" ) ]) programId)
                )
        , withCredentials = False
        }
        |> Http.send (Messages.OnTasksWithSize <| Maybe.withDefault -1 programId)


getTasksByStatus : String -> String -> TaskStatus -> Cmd Messages.Msg
getTasksByStatus token author taskStatus =
    let
        taskStatusToString status =
            case taskStatus of
                InQueue ->
                    "free"

                Executing ->
                    "executing"

                Completed ->
                    "completed"
    in
        Http.request
            { body = Http.emptyBody
            , expect = Http.expectJson Decode.tasksDecoder
            , headers = [ Http.acceptJsonHeader, Http.authHeader token ]
            , method = "GET"
            , timeout = Nothing
            , url =
                Http.makeUri "tasks"
                    [ ( "author", "eq." ++ author ), ( "status", "eq." ++ (taskStatusToString taskStatus) ) ]
            , withCredentials = False
            }
            |> Http.send Messages.OnTasksByStatus


getContent : String -> Int -> Cmd Messages.Msg
getContent token executionResultId =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson Decode.contentDecoder
        , headers = [ Http.authHeader token, Http.preferHeader (Singular) ]
        , method = "GET"
        , timeout = Nothing
        , url =
            Http.makeUri "execution_results"
                [ ( "id", "eq." ++ (toString executionResultId) )
                , ( "select", "content" )
                ]
        , withCredentials = False
        }
        |> Http.send (Messages.OnContent executionResultId)


getTasksStatus : String -> Cmd Messages.Msg
getTasksStatus token =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson Decode.tasksStatusDecoder
        , headers = [ Http.authHeader token ]
        , method = "GET"
        , timeout = Nothing
        , url = Http.makeUri "tasks_status" []
        , withCredentials = False
        }
        |> Http.send Messages.OnTasksStatus
