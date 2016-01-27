module Main where

import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import List
import History
import Http exposing (Error)
import Dict
import Json.Decode as Decode exposing ((:=))
import Task exposing (Task)
import Erl exposing (Url, Query)
import Debug
import Markdown
import Maybe exposing (withDefault)
import OnePageStack.Types exposing (..)
import OnePageStack.Server exposing (..)
import OnePageStack.Provider.Post exposing (postProvider)
import OnePageStack.Provider.Index exposing (indexProvider)

-- MODEL

providers : Providers
providers = Dict.fromList [("post", postProvider)]

main = serverOutput

port locationIn : Signal String

port tasks : Signal (Task String ())
port tasks = server indexProvider providers <| currentLocation locationIn
