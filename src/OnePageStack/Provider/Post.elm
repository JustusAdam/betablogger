module OnePageStack.Provider.Post (fetchPost) where

import Task exposing (Task)
import Html exposing (Html)
import Http
import Markdown
import Erl exposing (Query, Url)
import Dict
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import OnePageStack.Provider.Index exposing (postMetaUrl, postMetaDecoder)
import Path.Url exposing ((</>))
import Json.Decode as Decode
import List.Extra as LE


type alias Post = String


fetchPost : String -> String -> Task String (Html, Maybe String, Maybe String)
fetchPost basePath page =
  Task.mapError toString <|
  Http.getString (basePath </> "posts" </> page) `Task.andThen` \content ->
  Http.get (Decode.list postMetaDecoder) (postMetaUrl basePath) `Task.andThen` \posts ->
  let
    (title, descr) = case LE.find (\p -> p.location == page) posts of
                      Nothing -> (Nothing, Nothing)
                      Just post -> (Just post.title, post.description)
  in
    Task.succeed (Markdown.toHtml content, title, descr)
