module Main where

import Dict
import Task exposing (Task)
import OnePageStack.Types exposing (..)
import OnePageStack.Server exposing (..)
import OnePageStack.Provider.Post exposing (postProvider)
import OnePageStack.Provider.Index exposing (indexProvider)
import OnePageStack.Template exposing (withTemplate)
import Template exposing (template)

-- MODEL

providers : Providers
providers = Dict.fromList [("post", withTemplate template (postProvider "test-data"))]

main = serverOutput

port locationIn : Signal String

port tasks : Signal (Task String ())
port tasks = server (withTemplate template <| indexProvider "test-data") providers <| currentLocation locationIn
