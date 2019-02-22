module Programs.Encoders exposing (..)

import Json.Encode as Encode


code : String -> Encode.Value
code code =
    Encode.object [ ( "code", Encode.string code ) ]


addToScope : Int -> Int -> Encode.Value
addToScope currentProgram toAddProgram =
    Encode.object
        [ ( "program", Encode.int currentProgram )
        , ( "scope_program", Encode.int toAddProgram )
        ]


runProgram : Int -> Encode.Value
runProgram id =
    Encode.object
        [ ( "status", Encode.string "free" )
        , ( "program", Encode.int id )
        ]


newProgram : String -> String -> Encode.Value
newProgram name description =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "description", Encode.string description )
        , ( "code", Encode.string "" )
        ]
