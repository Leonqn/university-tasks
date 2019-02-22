module Programs.Update exposing (..)

import Programs.Messages exposing (Msg(..))
import Programs.Model as Model exposing (Model)
import Programs.Commands as Commands
import Common.Utils as Utils
import Port
import Navigation
import Routing
import Dict
import Common.Dict as Dict


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update token msg model =
    let
        updateName newProgram name =
            { newProgram | name = Just name }

        updateDescription newProgram description =
            { newProgram | description = description }

        resetFetching x =
            { x | fetching = Nothing }

        stopFetchingAndSetError x error =
            { x | fetching = Just False, error = Just error }

        resetError x =
            { x | error = Nothing }

        stopFetching programs =
            { programs | fetching = Just False }

        startFetching x =
            case x.fetching of
                Nothing ->
                    { x | fetching = Just True }

                _ ->
                    x
    in
        case msg of
            GetContent programId ->
                { model | executionResults = resetFetching model.executionResults } ! [ Commands.getContent token programId, Utils.delay500 ExecutionResultsFetch ]

            OnContent executionResultId result ->
                case result of
                    Ok content ->
                        let
                            updateExecutionResults executionResults =
                                { executionResults
                                    | items =
                                        Dict.updateIfPresent
                                            executionResultId
                                            (\x -> { x | content = Just content })
                                            executionResults.items
                                    , fetching = Just False
                                    , count = 0
                                }
                        in
                            { model | executionResults = updateExecutionResults model.executionResults } ! [ Port.downloadZip content ]

                    Err err ->
                        { model | executionResults = stopFetchingAndSetError model.executionResults err } ! []

            GetExecutionResults ids ->
                { model | executionResults = resetFetching model.executionResults } ! [ Commands.getExecutionResultsByTaskIds token ids, Utils.delay500 ExecutionResultsFetch ]

            OnExecutionResults result ->
                case result of
                    Ok result ->
                        let
                            updateExecutionResults executionResults =
                                { executionResults
                                    | items = Dict.union executionResults.items (Dict.ofList .id result)
                                    , fetching = Just False
                                    , count = 0
                                }
                        in
                            { model | executionResults = updateExecutionResults model.executionResults } ! []

                    Err err ->
                        { model | executionResults = stopFetchingAndSetError model.executionResults err } ! []

            GetTasks programId page ->
                { model | tasks = resetFetching model.tasks } ! [ Commands.getTasks token (Just programId) page, Utils.delay500 TasksFetch ]

            OnTasksWithSize programId result ->
                case result of
                    Ok ( size, result ) ->
                        let
                            updateTasks tasks =
                                { tasks
                                    | items = Dict.union tasks.items (Dict.ofList .id result)
                                    , fetching = Just False
                                    , count = size
                                }

                            updateProgram programs =
                                { programs
                                    | items = Dict.updateIfPresent programId (\x -> { x | tasks = List.map .id result }) programs.items
                                }

                            completedTasks =
                                List.filterMap
                                    (\x ->
                                        if x.status == Model.Completed then
                                            Just x.id
                                        else
                                            Nothing
                                    )
                                    result
                        in
                            { model | tasks = updateTasks model.tasks, programs = updateProgram model.programs }
                                ! [ Commands.getExecutionResultsByTaskIds token completedTasks ]

                    Err err ->
                        { model | tasks = stopFetchingAndSetError model.tasks err } ! []

            GetTasksByStatus author status ->
                { model | tasks = resetFetching model.tasks }
                    ! [ Commands.getTasksByStatus token author status
                      , Utils.delay500 TasksFetch
                      ]

            OnTasksByStatus _ ->
                model ! []

            GetPrograms page filter ->
                let
                    resetFetching programs =
                        { programs | fetching = Nothing }
                in
                    { model | filter = filter, programs = resetFetching model.programs }
                        ! [ Commands.getPrograms token page filter, Utils.delay500 ProgramsFetch ]

            OnProgramsWithSize result ->
                case result of
                    Ok ( size, result ) ->
                        let
                            updatePrograms programs =
                                { programs
                                    | items = Dict.union programs.items (Dict.ofList .id result)
                                    , fetching = Just False
                                    , count = size
                                    , showing = List.map .id result
                                }
                        in
                            { model | programs = updatePrograms model.programs } ! []

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []

            OnPrograms result ->
                case result of
                    Ok result ->
                        let
                            updatePrograms programs =
                                { programs
                                    | items = Dict.union programs.items (Dict.ofList .id result)
                                    , fetching = Just False
                                }
                        in
                            { model | programs = updatePrograms model.programs } ! []

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []

            GetProgram id tasksPage ->
                case Dict.get id model.programs.items of
                    Just _ ->
                        update token (GetTasks id tasksPage) model

                    Nothing ->
                        { model | programs = resetFetching model.programs, tasks = resetFetching model.tasks, executionResults = resetFetching model.executionResults }
                            ! [ Commands.getProgram token id
                              , Commands.getTasks token (Just id) 1
                              , Utils.delay500 ProgramsFetch
                              , Utils.delay500 TasksFetch
                              ]

            OnProgram result ->
                case result of
                    Ok program ->
                        let
                            insertProgram programs =
                                { programs | items = Dict.insert program.id program programs.items, fetching = Just False }
                        in
                            { model | programs = insertProgram model.programs }
                                ! case program.scope of
                                    [] ->
                                        []

                                    list ->
                                        [ Commands.getProgramsByIds token program.scope ]

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []

            RunProgram id ->
                { model | tasks = resetFetching model.tasks } ! [ Commands.runProgram token id, Utils.delay500 TasksFetch ]

            OnProgramRunned result ->
                case result of
                    Ok task ->
                        let
                            updatePrograms programs =
                                { programs
                                    | items =
                                        Dict.updateIfPresent
                                            task.program
                                            (\x -> { x | tasks = task.id :: x.tasks })
                                            programs.items
                                }

                            insertTask tasks =
                                { tasks | items = Dict.insert task.id task tasks.items, fetching = Just False }
                        in
                            { model
                                | programs = updatePrograms model.programs
                                , tasks = insertTask model.tasks
                            }
                                ! []

                    Err err ->
                        { model | tasks = stopFetchingAndSetError model.tasks err } ! []

            AddToScope currentProgram programToAdd ->
                { model | programs = resetFetching model.programs } ! [ Commands.addToScope token currentProgram programToAdd.id, Utils.delay500 ProgramsFetch ]

            OnAddToScope currentProgram toAddProgram result ->
                case result of
                    Ok _ ->
                        let
                            updatePrograms programs =
                                { programs
                                    | items =
                                        Dict.update
                                            currentProgram
                                            (Maybe.map (\x -> { x | scope = toAddProgram :: x.scope }))
                                            programs.items
                                    , fetching = Just False
                                }
                        in
                            { model | programs = updatePrograms model.programs } ! []

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []

            RemoveFromScope currentProgram programToAdd ->
                { model | programs = resetFetching model.programs } ! [ Commands.removeFromScope token currentProgram programToAdd, Utils.delay500 ProgramsFetch ]

            OnRemoveFromScope currentProgram toRemoveProgram result ->
                case result of
                    Ok _ ->
                        let
                            updatePrograms programs =
                                { programs
                                    | items =
                                        Dict.updateIfPresent
                                            currentProgram
                                            (\x -> { x | scope = List.filter ((/=) toRemoveProgram) x.scope })
                                            programs.items
                                    , fetching = Just False
                                }
                        in
                            { model | programs = updatePrograms model.programs } ! []

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []

            UpdateCode programId code ->
                let
                    updatePrograms programs =
                        { programs | fetching = Nothing, items = Dict.update programId (Maybe.map (\x -> { x | code = code })) programs.items }
                in
                    { model | programs = updatePrograms model.programs }
                        ! [ Commands.updateCode token programId code, Utils.delay500 ProgramsFetch ]

            OnCodeUpdated result ->
                case result of
                    Ok _ ->
                        { model | programs = stopFetching model.programs } ! []

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []

            CreateProgram ->
                case model.newProgram.name of
                    Just name ->
                        { model | showAddProgramModal = False, programs = resetFetching model.programs }
                            ! [ Commands.createProgram token name model.newProgram.description, Utils.delay500 ProgramsFetch ]

                    _ ->
                        model ! []

            OnProgramCreated result ->
                case result of
                    Ok program ->
                        { model | programs = stopFetching model.programs } ! [ Navigation.newUrl (Routing.program program.id 1) ]

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []

            GetTasksStatus ->
                --todo maybe delay
                { model | tasksStatus = resetFetching model.tasksStatus } ! [ Commands.getTasksStatus token ]

            OnTasksStatus result ->
                case result of
                    Ok tasksStatus ->
                        let
                            setTasksStatus status =
                                { status | items = tasksStatus, fetching = Just False }
                        in
                            { model | tasksStatus = setTasksStatus model.tasksStatus }! [ ]

                    Err err ->
                        { model | programs = stopFetchingAndSetError model.programs err } ! []


            DownloadZip hex ->
                model ! [ Port.downloadZip hex ]

            SetName name ->
                { model | newProgram = updateName model.newProgram name } ! []

            SetDescription description ->
                { model | newProgram = updateDescription model.newProgram description } ! []

            ProgramsFetch ->
                { model | programs = startFetching model.programs } ! []

            ExecutionResultsFetch ->
                { model | executionResults = startFetching model.executionResults } ! []

            TasksFetch ->
                { model | tasks = startFetching model.tasks } ! []

            ToggleAddProgramModal ->
                { model | showAddProgramModal = not model.showAddProgramModal } ! []

            CloseProgramsError ->
                { model | programs = resetError model.programs } ! []

            CloseTasksError ->
                { model | tasks = resetError model.tasks } ! []

            CloseExecutionResultsError ->
                { model | executionResults = resetError model.executionResults } ! []

            Search page addToScope ->
                if page == 1 then
                    model ! []
                else
                    case addToScope of
                        Just addToScope ->
                            model ! [ Navigation.newUrl (Routing.addToScope 1 addToScope) ]

                        Nothing ->
                            model ! [ Navigation.newUrl (Routing.programs 1) ]
