module Common.Views.Paging exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


--todo this is very bad


paging : Int -> Int -> (Int -> String) -> Html msg
paging currentPage totalElements getUrl =
    let
        pagesCount =
            ceiling ((toFloat totalElements) / 21)

        makeLinks =
            List.map
                (\x ->
                    li []
                        [ a [ classList [ ( "pagination-link", True ), ( "is-current", currentPage == x ) ], href (getUrl x) ] [ text (toString x) ] ]
                )
    in
        if (pagesCount == 0) then
            div [] []
        else
            nav [ class "pagination is-centered" ]
                [ a [ classList [ ( "pagination-previous", True ), ( "is-disabled", currentPage == 1 ) ], style [ ( "margin-right", "0.75rem" ) ], href (getUrl <| currentPage - 1) ]
                    [ text "Previous" ]
                , a [ classList [ ( "pagination-next", True ), ( "is-disabled", currentPage == pagesCount ) ], href (getUrl <| currentPage + 1) ]
                    [ text "Next page" ]
                , ul [ class "pagination-list" ]
                    (if pagesCount < 8 then
                        List.range 1 pagesCount |> makeLinks
                     else
                        [ li []
                            [ a [ classList [ ( "pagination-link", True ), ( "is-current", currentPage == 1 ) ], href (getUrl currentPage) ]
                                [ text "1" ]
                            ]
                        ]
                            ++ (if currentPage < 4 then
                                    (List.range 2 4 |> makeLinks)
                                        ++ [ li []
                                                [ span [ class "pagination-ellipsis" ]
                                                    [ text "…" ]
                                                ]
                                           ]
                                        ++ [ li []
                                                [ a [ classList [ ( "pagination-link", True ), ( "is-current", currentPage == pagesCount ) ] ]
                                                    [ text (toString (pagesCount)) ]
                                                ]
                                           ]
                                else
                                    ([ li []
                                        [ span [ class "pagination-ellipsis" ]
                                            [ text "…" ]
                                        ]
                                     ]
                                    )
                                        ++ (if (currentPage < pagesCount - 2) then
                                                (List.range
                                                    (currentPage - 1)
                                                    (currentPage + 1)
                                                    |> makeLinks
                                                )
                                                    ++ [ li []
                                                            [ span [ class "pagination-ellipsis" ]
                                                                [ text "…" ]
                                                            ]
                                                       ]
                                                    ++ [ li []
                                                            [ a [ classList [ ( "pagination-link", True ), ( "is-current", currentPage == pagesCount ) ] ]
                                                                [ text (toString (pagesCount)) ]
                                                            ]
                                                       ]
                                            else
                                                List.range (pagesCount - 3) pagesCount |> makeLinks
                                           )
                               )
                    )
                ]
