module Main where

import Dict
import Task exposing (Task)
import OnePageStack.Types exposing (..)
import OnePageStack.Server exposing (..)
import OnePageStack.Provider exposing (mkProvider)
import OnePageStack.Provider.Post exposing (fetchPost)
import OnePageStack.Provider.Index exposing (fetchIndex)
import Template exposing (renderPost, renderIndex)
import Path.Url exposing ((</>))

-- MODEL


basePath : String
basePath = "blog-data"


indexProvider : String -> Handler
indexProvider basePath = mkProvider (fetchIndex basePath) (renderIndex basePath)


postProvider : String -> Handler
postProvider basePath = mkProvider (fetchPost basePath << .query << .currentUrl) renderPost


providers : Providers
providers = Dict.fromList
  [("post", (postProvider (basePath </> "posts")))]

main = serverOutput

port locationIn : Signal String

port tasks : Signal (Task String ())
port tasks =
  server
    (indexProvider basePath)
    providers
    (currentLocation locationIn)
