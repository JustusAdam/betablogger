module OnePageStack.Provider.Projects where


import OnePageStack.Types exposing (..)
import Json.Decode as Decode exposing ((:=))
import Http
import Task
import Debug
import Path.Url exposing ((</>), addExtension)
import Date exposing (Date)
import Util


type alias Project =
  { id : Int
  , name : String
  , fullName : String
  , description : String
  , stars : Int
  , watchers : Int
  , forks : Int
  , language : Maybe String
  , isFork : Bool
  , htmlUrl : String
  , homepage : Maybe String
  , hasIssues : Bool
  , hasPages : Bool
  , hasWiki : Bool
  , createdAt : Date
  , forksUrl : String
  , starsUrl : String
  , watchUrl : String
  , pushedAt : Date
  , languagesUrl : Maybe String
  }



projectDecoder : Decode.Decoder Project
projectDecoder =
  Decode.object8 Project
    ("id" := Decode.int)
    ("name" := Decode.string)
    ("full_name" := Decode.string)
    ("description" := Decode.string)
    ("stargazers_count" := Decode.int)
    ("watchers_count" := Decode.int)
    ("forks_count" := Decode.int)
    (Decode.maybe ("language" := Decode.string))
  `Decode.andThen` \f1 ->
  Decode.object8 f1
    ("fork" := Decode.bool)
    ("html_url" := Decode.string)
    (Decode.maybe ("homepage" := Decode.string))
    ("has_issues" := Decode.bool)
    ("has_pages" := Decode.bool)
    ("has_wiki" := Decode.bool)
    ("created_at" := Util.decodeDate)
    ("forks_url" := Decode.string)
    `Decode.andThen` \f2 ->
    Decode.object4
      f2
      ("stargazers_url" := Decode.string)
      ("subscription_url" := Decode.string)
      ("pushed_at" := Util.decodeDate)
      (Decode.maybe ("languages_url" := Decode.string))




fetchProjects : String -> String -> Task.Task String (List Project)
fetchProjects basePath user =

  Task.mapError toString <|
  Http.get (Decode.list projectDecoder)
    <| basePath </> "github-data" </> user `addExtension` ".json"
