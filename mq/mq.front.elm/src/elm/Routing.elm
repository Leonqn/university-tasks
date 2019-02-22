module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), (<?>), s, int, string, map, oneOf, parseHash, intParam)


type Route
    = SignIn
    | Root
    | Programs Int (Maybe Int)
    | Program Int Int


router : Location -> Route
router location =
    oneOf
        [ map SignIn (s "signin")
        , map (\x -> Programs x Nothing) (s "programs" </> int)
        , map (\x y -> Programs x (Just y)) (s "programs" </> int </> s "add-to-scope" </> int)
        , map Program (s "programs" </> s "details" </> int </> int)
        , map Root (s "")
        ]
        |> \x ->
            parseHash x location
                |> Maybe.withDefault Root


signIn : String
signIn =
    "#signin"


programs : Int -> String
programs page =
    "#programs/" ++ (toString page)


program : Int -> Int -> String
program programId tasksPage =
    "#programs/details/" ++ (toString programId) ++ "/" ++ (toString tasksPage)


addToScope : Int -> Int -> String
addToScope programId page =
    "#programs/" ++ (toString page) ++ "/add-to-scope/" ++ (toString programId)


root : String
root =
    "#"
