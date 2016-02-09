module OnePageStack.Provider.Util where

import OnePageStack.Types exposing (..)
import Dict
import Task exposing (Task)
import Erl exposing (Query, Url)
import Html exposing (Html)
import History


mkProvider
  : (AppInterface -> String -> Task String a)
  -> (AppInterface -> a -> Task String Html)
  -> Handler
mkProvider fetchTask renderer interface r =
  let
    url = interface.currentUrl
  in
    fetchTask interface r
    `Task.andThen` renderer interface


withTemplate : (Html -> Html) -> Handler -> Handler
withTemplate template f interface r = Task.map template (f interface r)
