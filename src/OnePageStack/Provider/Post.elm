module OnePageStack.Provider.Post (fetchPost) where

import Task exposing (Task)
import Html exposing (Html)
import Http
import Markdown
import Erl exposing (Query, Url)
import Dict
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import Path.Url exposing ((</>))


type alias Post = String


fetchPost : String -> Query -> Task String Html
fetchPost basePath params =
  case Dict.get "page" params of
    Nothing -> Task.fail "No page specified"
    Just page ->
      Http.getString (basePath </> page)
      |> Task.map Markdown.toHtml
      |> Task.mapError toString
