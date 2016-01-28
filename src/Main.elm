module Main where

import Dict
import Task exposing (Task)
import OnePageStack.Types exposing (..)
import OnePageStack.Server exposing (..)
import OnePageStack.Provider.Post exposing (postProvider)
import OnePageStack.Provider.Index exposing (indexProvider)

-- MODEL

providers : Providers
providers = Dict.fromList [("post", postProvider "test-data")]

main = serverOutput

port locationIn : Signal String

port tasks : Signal (Task String ())
port tasks = server (indexProvider "test-data") providers <| currentLocation locationIn
