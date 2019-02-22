module Common.Views.ErrorView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Common.Maybe as Maybe

-- errorModal error =
--     case error of
--         _ ->
--             modal "Whoops! Some error occured" (div [] []) "error-modal"


errorModal : Maybe String -> msg -> Html msg
errorModal errorMessage msg =
    div [ classList [ ( "modal", True ), ( "is-active", Maybe.isJust errorMessage ) ] ]
        [ div [ class "modal-background", onClick msg ]
            []
        , div [ class "modal-card" ]
            [ header [ class "modal-card-head" ]
                [ p [ class "modal-card-title" ]
                    [ text "Whoops an error has occured" ]
                , button [ class "delete", onClick msg ]
                    []
                ]
            , section [ class "modal-card-body" ]
                [ text <| Maybe.withDefault "" errorMessage ]
            , footer [ class "modal-card-foot" ]
                [ button
                    [ class "button is-primary"
                    , attribute "data-dismiss" "modal"
                    , onClick msg
                    ]
                    [ text "Close" ]
                ]
            ]
        ]



--
-- errorNotification =
--     div [ class "notification is-danger" ]
--     [ button [ class "delete" ]
--         []
--     , text "Danger lorem ipsum dolor sit amet, consectetur  adipiscing elit lorem ipsum dolor sit amet,  consectetur adipiscing elit"
--     ]
--
-- dangerNotification =
--     div [ class "notification is-warning" ]
--     [ button [ class "delete" ]
--         []
--     , text "Warning lorem ipsum dolor sit amet, consectetur  adipiscing elit lorem ipsum dolor sit amet,  consectetur adipiscing elit"
--     ]
