module Programs.Model exposing (..)

import Date exposing (Date)
import Dict exposing (Dict)
import Http


type alias Program =
    { id : Int
    , name : String
    , description : Maybe String
    , author : String
    , code : String
    , createdAt : Date
    , scope : List Int
    , executionResults : List Int
    , tasks : List Int
    }


type alias NewProgram =
    { name : Maybe String
    , description : String
    }


type ExecutionStatus
    = Ok
    | Failed


type TaskStatus
    = InQueue
    | Executing
    | Completed


type alias ExecutionResult =
    { id : Int
    , status : ExecutionStatus
    , task : Int
    , program : Int
    , content : Maybe String
    }


type alias Task =
    { id : Int
    , status : TaskStatus
    , createdAt : Date
    , startedAt : Maybe Date
    , completedAt : Maybe Date
    , program : Int
    }


type alias Programs =
    { count : Int
    , items : Dict Int Program
    , fetching : Maybe Bool
    , showing : List Int
    , error : Maybe Http.Error
    }


type alias ExecutionResults =
    { count : Int
    , items : Dict Int ExecutionResult
    , fetching : Maybe Bool
    , error : Maybe Http.Error
    }


type alias Tasks =
    { count : Int
    , items : Dict Int Task
    , fetching : Maybe Bool
    , error : Maybe Http.Error
    }


type alias TasksStatus =
    { completed : Int
    , executing : Int
    , inQueue : Int
    }


type alias TasksStatusByProgram =
    { items : Dict Int TasksStatus
    , fetching : Maybe Bool
    , error : Maybe Http.Error
    }


type alias Model =
    { programs : Programs
    , executionResults : ExecutionResults
    , tasks : Tasks
    , tasksStatus : TasksStatusByProgram
    , filter : String
    , newProgram : NewProgram
    , showAddProgramModal : Bool
    }


init : Model
init =
    Model
        ({ count = 0, items = Dict.empty, fetching = Nothing, showing = [], error = Nothing })
        ({ count = 0, items = Dict.empty, fetching = Nothing, error = Nothing })
        ({ count = 0, items = Dict.empty, fetching = Nothing, error = Nothing })
        ({ items = Dict.empty, fetching = Nothing, error = Nothing })
        ""
        (NewProgram Nothing "")
        False
