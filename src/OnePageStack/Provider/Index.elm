module OnePageStack.Provider.Index (indexProvider) where

import Task exposing (Task)
import Json.Decode as Decode exposing ((:=))
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import Http
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Path.Url exposing ((</>))
import Date exposing (Date)
import Result exposing (Result(..))


type alias PostMeta =
  { location : String
  , title : String
  , description : Maybe String
  , date : Date
  }


fetchIndex : String -> a -> Task String (List PostMeta)
fetchIndex basePath _ =
  basePath </> "posts.json"
  |> Http.get (Decode.list postMetaDecoder)
  |> Task.mapError toString


renderIndex : Targeter -> (List PostMeta) -> Html
renderIndex chgr =
  List.sortBy (Date.toTime << .date)
  >> List.reverse
  >> List.map (\pm ->
          li [ class "element" ]
            [ a [ onClick chgr (navigate "post" pm.location)]
                ([ h3 [] [text pm.title]]
                ++ case pm.description of
                    Nothing -> []
                    Just d -> [p [ class "description" ] [text d]]
                )
            ])
    -- >> List.intersperse (li [class "separator"] [])
    >> ul [ class "post-list" ]

indexProvider : String -> Handler
indexProvider basePath = mkProvider (fetchIndex basePath) renderIndex


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
