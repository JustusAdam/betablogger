module Main where

import Dict
import Task exposing (Task)
import OnePageStack.Types exposing (..)
import OnePageStack.Server exposing (..)
import OnePageStack.Provider.Post exposing (postProvider)
import OnePageStack.Provider.Index exposing (indexProvider)
import OnePageStack.Template exposing (withTemplate)
import Template exposing (postTemplate, pageTemplate, indexTemplate)
import Path.Url exposing ((</>))

-- MODEL


basePath : String
basePath = "blog-data"


providers : Providers
providers = Dict.fromList [("post", withTemplate postTemplate (postProvider (basePath </> "posts")))]

main = serverOutput

port locationIn : Signal String

port tasks : Signal (Task String ())
port tasks = 
    server 
    (withTemplate (indexTemplate basePath) <| indexProvider basePath) 
    providers 
    (currentLocation locationIn)
