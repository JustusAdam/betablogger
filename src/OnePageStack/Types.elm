module OnePageStack.Types where

import Html exposing (Html)
import Erl exposing (Url, Query)
import Task exposing (Task)
import Dict

type Page
  = Page Html
  | PageLoading
  | PageNotFound String

type alias LocationChange = Maybe Query
type alias PostMeta = { location : String, title : String }
type alias Targeter = Signal.Address LocationChange
type alias ContentHook = Signal.Address Page
type alias ProviderFunc = AppInterface -> Task String ()
type alias Providers = Dict.Dict String ProviderFunc
type alias AppInterface =
  { canvas : ContentHook
  , navigator : Targeter
  , currentUrl : Url
  }
