module OnePageStack.Provider.Util where

import OnePageStack.Types exposing (..)
import Dict
import Task exposing (Task)
import Erl exposing (Query, Url)
import Html exposing (Html)
import History


mkProvider
  : (AppInterface -> Task String a)
  -> (AppInterface -> a -> Task String Html)
  -> Handler
mkProvider fetchTask renderer interface =
  let
    url = interface.currentUrl
  in
    History.setPath (Erl.toString url)
    `Task.andThen` \_ -> fetchTask interface
    `Task.andThen` renderer interface



navigate : String -> String -> LocationChange
navigate s1 s2 = Just <| Dict.fromList [("type", s1), ("page", s2)]


withTemplate : (Html -> Html) -> Handler -> Handler
withTemplate template f interface = Task.map template (f interface)
