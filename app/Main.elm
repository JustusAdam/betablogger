module Main where

import Dict
import Task exposing (Task)
import Util exposing (const)
import OnePageStack.Types exposing (..)
import OnePageStack.Server exposing (..)
import OnePageStack.Provider exposing (mkProvider)
import OnePageStack.Provider.Post exposing (fetchPost)
import OnePageStack.Provider.Index exposing (fetchIndex)
import OnePageStack.Provider.Projects exposing (fetchProjects)
import Template exposing (renderPost, renderIndex, renderProjects)
import Path.Url exposing ((</>))

-- MODEL


(=>) = (,)


basePath : String
basePath = "blog-data"


indexProvider : String -> Handler
indexProvider basePath = mkProvider (\i _ -> fetchIndex basePath i) (renderIndex basePath)


postProvider : String -> Handler
postProvider basePath = mkProvider (const <| fetchPost basePath) renderPost


projectProvider : String -> String -> Handler
projectProvider basePath user = mkProvider (\_ _ -> fetchProjects basePath user) renderProjects


providers : Providers
providers = Dict.fromList
  [ "post" => postProvider basePath
  , "" => indexProvider basePath
  , "projects" => projectProvider basePath "JustusAdam"
  ]

main = serverOutput

port tasks : Signal (Task String ())
port tasks =
  server
    providers

port lc : Signal (Task String ())
port lc = lcTask
