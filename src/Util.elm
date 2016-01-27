module Util where

import Task

unless : Bool -> Task a () -> Task a ()
unless b = if b then constant (succeed ()) else identity


when : Bool -> Task a () -> Task a ()
when = unless << not
