module Programs.Messages exposing (..)

import Programs.Model as Model exposing (Program, ExecutionResult)
import Http
import Dict exposing (Dict)

type Msg
    = GetPrograms Int String
    | GetProgram Int Int
    | OnProgramsWithSize (Result Http.Error ( Int, List Model.Program ))
    | OnPrograms (Result Http.Error (List Model.Program))
    | OnProgram (Result Http.Error Model.Program)
      --
    | GetContent Int
    | OnContent Int (Result Http.Error String)
      --
    | GetExecutionResults (List Int)
    | OnExecutionResults (Result Http.Error (List ExecutionResult))
      --
    | CreateProgram
    | OnProgramCreated (Result Http.Error Model.Program)
      --
    | RunProgram Int
    | OnProgramRunned (Result Http.Error Model.Task)
      --
    | AddToScope Int Model.Program
    | OnAddToScope Int Int (Result Http.Error ())
      --
    | RemoveFromScope Int Int
    | OnRemoveFromScope Int Int (Result Http.Error ())
      --
    | UpdateCode Int String
    | OnCodeUpdated (Result Http.Error ())
      --
    | GetTasks Int Int
    | OnTasksWithSize Int (Result Http.Error ( Int, List Model.Task ))
      --
    | GetTasksByStatus String Model.TaskStatus
    | OnTasksByStatus (Result Http.Error (List Model.Task))
      --
    | GetTasksStatus
    | OnTasksStatus (Result Http.Error (Dict Int Model.TasksStatus))
      --
    | ProgramsFetch
    | ExecutionResultsFetch
    | TasksFetch
    | ToggleAddProgramModal
    | CloseProgramsError
    | CloseTasksError
    | CloseExecutionResultsError
    | SetName String
    | SetDescription String
    | DownloadZip String
    | Search Int (Maybe Int)
