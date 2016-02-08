module OnePageStack.Provider.Index
  ( fetchIndex
  , PostMeta
  , postMetaUrl
  , postMetaDecoder
  ) where

import Task exposing (Task)
import Json.Decode as Decode exposing ((:=))
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import Http
import Path.Url exposing ((</>))
import Date exposing (Date)
import Result exposing (Result(..))


type alias PostMeta =
  { location : String
  , title : String
  , description : Maybe String
  , date : Date
  }


postMetaUrl basePath = basePath </> "posts.json"


fetchIndex : String -> AppInterface -> Task String (List PostMeta)
fetchIndex basePath _ =
  basePath </> "posts.json"
  |> Http.get (Decode.list postMetaDecoder)
  |> Task.mapError toString


postMetaDecoder : Decode.Decoder PostMeta
postMetaDecoder =
  Decode.object4
    PostMeta
    ("location" := Decode.string)
    ("title" := Decode.string)
    (Decode.maybe ("description" := Decode.string))
    ("date" := Decode.string `Decode.andThen`
                  \s -> case Date.fromString s of
                          Err e -> Decode.fail e
                          Ok val -> Decode.succeed val)
