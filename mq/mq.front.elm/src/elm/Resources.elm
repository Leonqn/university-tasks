module Resources exposing (..)


wrongEmailOrPass : String
wrongEmailOrPass =
    "Wrong email or password"

timeout : String
timeout =
    "Timeout. Please try again later"

networkError : String
networkError =
    "NetworkError. Please check your internet connection"

unexpectedPayload : String -> String
unexpectedPayload msg =
    "Server returns bad response. " ++ msg

badUrl : String -> String
badUrl url =
    "Bad url. " ++ url
