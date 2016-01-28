module OnePageStack.Provider.Util where

import OnePageStack.Types exposing (..)
import Dict
import Task exposing (Task)
import Erl exposing (Query, Url)
import Html exposing (Html)
import History


mkProvider : (Query -> Task String a) -> (Targeter -> a -> Html) -> ProviderFunc
mkProvider fetchTask renderer interface =
  let
    url = interface.currentUrl
  in
    History.setPath (Erl.toString url)
    `Task.andThen` \_ -> (fetchTask url.query)
    `Task.andThen` (Task.succeed << renderer interface.navigator)



navigate : String -> String -> LocationChange
navigate s1 s2 = Just <| Dict.fromList [("type", s1), ("page", s2)]
