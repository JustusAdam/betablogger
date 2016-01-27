module OnePageStack.Provider.Index (indexProvider) where

import Task exposing (Task)
import Json.Decode as Decode exposing ((:=))
import OnePageStack.Types exposing (..)
import OnePageStack.Provider.Util exposing (..)
import Http
import Html exposing (..)
import Html.Events exposing (onClick)

fetchIndex : a -> Task String (List PostMeta)
fetchIndex _ = Task.mapError toString <| Http.get (Decode.list postMetaDecoder) "index.json"

renderIndex : Targeter -> (List PostMeta) -> Html
renderIndex chgr l =
  ul []
    <| List.map (\pm -> li [] [a [ onClick chgr (navigate "post" pm.location) ] [ text pm.title ]])
        l

indexProvider : ProviderFunc
indexProvider = mkProvider fetchIndex renderIndex

postMetaDecoder : Decode.Decoder PostMeta
postMetaDecoder = Decode.object2 PostMeta ("location" := Decode.string) ("title" := Decode.string)
