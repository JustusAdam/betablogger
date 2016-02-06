module OnePageStack.Provider.Projects where


import OnePageStack.Types exposing (..)
import Json.Decode as Decode exposing ((:=))
import Http
import Task
import Debug


type alias Project =
  { id : Int
  , name : String
  , fullName : String
  , description : String
  , starts : Int
  , watchers : Int
  , forks : Int
  , language : String
  , isFork : Bool
  , htmlUrl : String
  , homepage : String
  , hasIssues : Bool
  , hasPages : Bool
  , hasWiki : Bool
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
    ("language" := Decode.string)
  `Decode.andThen` \f ->
  Decode.object6 f
    ("fork" := Decode.bool)
    ("html_url" := Decode.string)
    ("homepage" := Decode.string)
    ("has_issues" := Decode.bool)
    ("has_pages" := Decode.bool)
    ("has_wiki" := Decode.bool)


fetchProjects : String -> Task.Task String (List Project)
fetchProjects user =

  Task.mapError toString <|
  Http.get (Decode.list projectDecoder)
    <| Debug.log "Url" <| "http://github.com/users/" ++ user ++ "/repos"
