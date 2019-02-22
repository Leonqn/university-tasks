module Auth.Update exposing (..)

import Auth.Messages exposing (Msg(..))
import Auth.Model exposing (Model)
import Auth.Commands
import Port
import Common.Utils as Utils


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        updateEmail creds email =
            { creds | email = Just email }

        updatePassword creds password =
            { creds | password = Just password }

        updateRemember creds =
            { creds | remember = not creds.remember }
    in
        case msg of
            SetEmail x ->
                { model | credentials = updateEmail model.credentials x, error = Nothing } ! []

            SetPassword x ->
                { model | credentials = updatePassword model.credentials x, error = Nothing } ! []

            ToggleRemember ->
                { model | credentials = updateRemember model.credentials } ! []

            SignIn ->
                case ( model.credentials.email, model.credentials.password ) of
                    ( Just email, Just password ) ->
                        { model | error = Nothing, loading = Nothing }
                            ! [ Auth.Commands.signin email password, Utils.delay500 ToggleLoading ]

                    _ ->
                        model ! []

            SignOut ->
                { model | userInfo = Nothing } ! [ Port.clear () ]

            OnToken userInfo ->
                case userInfo of
                    Ok userInfo ->
                        { model | userInfo = Just userInfo, loading = Just False }
                            ! [ if model.credentials.remember then
                                    Port.store userInfo
                                else
                                    Cmd.none
                              ]

                    Err err ->
                        { model | error = Just err, loading = Just False }
                            ! []

            ToggleLoading ->
                case model.loading of
                    Nothing ->
                        { model | loading = Just True }
                            ! []

                    _ ->
                        model ! []
