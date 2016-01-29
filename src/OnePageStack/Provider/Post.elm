module OnePageStack.Provider.Post (postProvider) where

import Task exposing (Task)
import Html exposing (Html)
import Http
import Markdown
import Erl exposing (Query, Url)
import Dict
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import Path.Url exposing ((</>))

fetchPost : String -> Query -> Task String String
fetchPost basePath params =
  case Dict.get "page" params of
    Nothing -> Task.fail "No page specified"
    Just page -> Task.mapError toString <| Http.getString (basePath </> page)

renderPost : a -> String -> Html
renderPost _ = Markdown.toHtml

postProvider : String -> Handler
postProvider basePath = mkProvider (fetchPost basePath) renderPost
