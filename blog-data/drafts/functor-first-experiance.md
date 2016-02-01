---
title: I met the Functor
description: "I've had some first experiences with Haskell Functors"
author: Justus
---

{% assign snippets = site.data.snippets.functor %} 

I have spent a lot of time with [Haskell](http://haskell.org) lately, trying to get to know the language better. I basically want to be able to solve any problem I have using it, because its concepts are just so very useful.

One of the things I got in contact with just very recently was Functors. Now, any of you that have dealt a fair with Haskell before will now ask "which Functor?". Because there are two.

I only knew of the "easy" one. The `Data.Functor` which is 'used for types that can be mapped over' [source](https://downloads.haskell.org/~ghc/latest/docs/html/libraries/base/Data-Functor.html). Essentially it is a type of container, that allows you to apply some function to its contents, yielding a new instance of the container.

I turns out however, there's another Functor, in `Control.Applicative` also refered to as "Applicative Functor". And this applicative Functor is radically different to the simple mappable `Data.Functor` Functor.

The reason I even came in contact with the (applicative) Functor was that it was used by a [command line parsing library](https://hackage.haskell.org/package/options) I wanted to use, to add some nice(ly formatted) command line arguments to [my project](http://github.com/JustusAdam/schedule-planner) and the code I eventually pieced together from the examples that the documentation was providing looked like this:

{% include haskell-snippet.html snippet=snippets.cmd_args %}

I had of course never seen either `pure` or `<*>` before, because I'm a complete Haskell noob, but seing it being used prompted me to look at it in more depth and try to understand maybe not how it necassarily works, but rather what it does and how I may even use it.

It tuned out that that was a very good decision, because this Functor is actually very useful. It allows you to take functions and combine them such that when the resulting Functor (yes like a Monad this operation yields an instance of the wrapper itself) is being 'called' with an argument, it calls all each function with that argument and then some base function with all results. One of the simple and practical applications I have found for this is doing several calculations on a single input, accumulating results in a tuple or transforming fome fields of some data type into a tuple.

{% include haskell-snippet.html snippet=snippets.tuples %}


