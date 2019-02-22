module Auth.View exposing (signInForm, signOutLink)

import Html exposing (..)
import Html.Attributes exposing (..)
import Auth.Model exposing (Model, FieldError(..), Credentials)
import Html.Events exposing (onInput, onSubmit, onClick)
import Auth.Messages exposing (Msg(..))
import Common.Errors as Errors
import Validate
import List.Extra as List
import Tuple
import Common.Validate as Validate
import Resources
import Http

--todo hack
signOutLink : Html Msg
signOutLink =
    a [ class "is-tab nav-item", onClick SignOut ] [ text "Sign out" ]


signInForm : Model -> Html Msg
signInForm { credentials, userInfo, error } =
    let
        validationResults =
            validate credentials

        getError field =
            List.find (Tuple.first >> (==) field) validationResults
                |> Maybe.map Tuple.second

        ( hasDanger, serverErrorMsg ) =
            case error of
                Just error ->
                    ( "is-danger", p [ class "help is-danger" ] [ text (Errors.classifyError errorsClassifier error) ] )

                _ ->
                    ( "", div [] [] )
    in
        Html.form
            [ class ("control form-signin " ++ hasDanger)
            , novalidate True
            , onSubmit SignIn
            ]
            [ h2 [ class "title" ] [ text "Please sign in" ]
            , input "Email" "email" (getError Email) "fa-envelope" SetEmail
            , input "Password" "password" (getError Password) "fa-lock" SetPassword
            , checkbox "Remember me" ToggleRemember
            , signInBtn (not (List.isEmpty validationResults))
            , serverErrorMsg
            ]


signInBtn : Bool -> Html msg
signInBtn isDisabled =
    button [ class "button is-primary", type_ "submit", disabled isDisabled ] [ text "Sign in" ]


input :
    String
    -> String
    -> Maybe String
    -> String
    -> (String -> msg)
    -> Html msg
input label typ error icon onInp =
    --todo remove copy-paste
    case error of
        Just err ->
            p [ class "control has-icon" ]
                [ Html.input [ class "input is-danger", type_ typ, placeholder label, onInput onInp ] []
                , span [ class "icon is-small" ]
                    [ i [ class ("fa " ++ icon) ]
                        []
                    ]
                , span [ class "help is-danger" ]
                    [ text err ]
                ]
        Nothing ->
            p [ class "control has-icon" ]
                [ Html.input [ class "input", type_ typ, placeholder label, onInput onInp ] []
                , span [ class "icon is-small" ]
                    [ i [ class ("fa " ++ icon) ]
                        []
                    ]
                ]


checkbox : String -> Msg -> Html Msg
checkbox val onClk =
    p [ class "control" ]
        [ label [ class "checkbox " ]
            [ Html.input [ type_ "checkbox", onClick onClk ] []
            , text val
            ]
        ]


errorsClassifier : Http.Response String -> String
errorsClassifier { status } =
    case status.code of
        403 ->
            Resources.wrongEmailOrPass

        _ ->
            "Unknown error. " ++ status.message


validate : Credentials -> List ( FieldError, String )
validate =
    Validate.all
        [ \x ->
            case ( x.email, x.password ) of
                ( Nothing, _ ) ->
                    [ ( Init, "" ) ]

                ( _, Nothing ) ->
                    [ ( Init, "" ) ]

                _ ->
                    []
        , .email >> Validate.withMaybe (Validate.ifInvalidEmail ( Email, "Should be a valid email." ))
        , .password
            >> Validate.withMaybe
                (Validate.all
                    [ Validate.ifInvalid (String.length >> (>) 3) ( Password, "Password length should be greater than 3" )
                    , Validate.ifInvalid (String.length >> (<) 64) ( Password, "Password length should less than 64" )
                    ]
                )
        ]
