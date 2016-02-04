module OnePageStack.Types where

import Html exposing (Html)
import Erl exposing (Url, Query)
import Task exposing (Task)
import Dict

type Page
  = Page Html
  | PageLoading
  | PageNotFound String

type alias LocationChange = Maybe String
type alias Targeter = Signal.Address LocationChange
type alias ContentHook = Signal.Address Page
type alias Handler = AppInterface -> String -> Task String Html
type alias Providers = Dict.Dict String Handler
type alias AppInterface =
  { canvas : ContentHook
  , navigator : Targeter
  , currentUrl : String
  }
