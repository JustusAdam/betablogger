module OnePageStack.Template where

import Dict
import Task exposing (Task)
import Html exposing (Html)
import OnePageStack.Types exposing (..)


type alias Component = Maybe Html
type alias AcquireComponent = Task String Component
type alias Components = Dict.Dict String AcquireComponent
type alias TemplateBuilder a = Components -> Html -> Task String a
type alias Template = Html -> Task String Html


withComponents : Components -> TemplateBuilder Html -> Template
withComponents c tb = tb c


getComponent : String -> TemplateBuilder Component
getComponent selector components html =
  case Dict.get selector components of
    Just acq -> acq
    Nothing -> Task.succeed Nothing


andThen : TemplateBuilder a -> (a -> TemplateBuilder b) -> TemplateBuilder b
andThen ta f comp html = ta comp html `Task.andThen` \a -> f a comp html


render : (Html -> a) -> TemplateBuilder a
render a _ h = Task.succeed (a h)


return : a -> TemplateBuilder a
return a _ _ = Task.succeed a


acquired : Html -> AcquireComponent
acquired = Task.mapError toString << Task.succeed << Just


withTemplate : Template -> ProviderFunc -> ProviderFunc
withTemplate t f i = f i `Task.andThen` t
