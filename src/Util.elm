module Util where

import Task exposing (Task)
import Date
import Json.Decode as Decode
import Result.Extra as Res

const : a -> b -> a
const a _ = a

unless : Bool -> Task a () -> Task a ()
unless b = if b then const (Task.succeed ()) else identity


when : Bool -> Task a () -> Task a ()
when = unless << not


singleton : a -> List a
singleton a = [a]


first : (a -> b) -> (a, c) -> (b, c)
first f (a, c) = (f a, c)


decodeDate : Decode.Decoder Date.Date
decodeDate = Decode.string
  `Decode.andThen` (Date.fromString >> Res.mapBoth Decode.fail Decode.succeed)
