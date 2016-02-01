---
title: Unittesting in Haskell
author: Justus
---

{% assign snippets = site.data.snippets.hspec %}

I have, of late, been writing a bunch of smaller programs in [Haskell](https://haskell.org). Simple things like [counting some codelines][hlinecount], [renaming a lot of files simultaneously](https://github.com/JustusAdam/hrename) and [pinging a server until it answers](https://github.com/JustusAdam/hpingserver).
For the most part, if your project is as small as these are, there's no automated testing required. The functionality has a very small scope and is well defined so it is usually enough to just see if it works yourself.

[hlinecount]: https://github.com/JustusAdam/hlinecount

However my code line counting tool ([hlinecount]) is different. I wanted to make it more extensible and not hard code the actual counters, file filters and so on. So I had to refactor the code in a mayor way.[^hlcrefac]

[^hlcrefac]:
    What I ended up doing was creating three `newtype`'s [`Counter`](https://github.com/JustusAdam/hlinecount/blob/master/src/LineCount/Counter.hs), [`FileFilter`](https://github.com/JustusAdam/hlinecount/blob/master/src/LineCount/Filter.hs) and [`Selector`](https://github.com/JustusAdam/hlinecount/blob/master/src/LineCount/Select.hs). It is then possible to define individual filters and counters etc., with a small and well defined scope, that can be chained together (they form a Monoid since they are just functions).
    Each of the source files for these Structures defines the basic ones, accumulates them in a List, which is then folded over to create the actual Filter/Counter/Selector.

As is to be expected following the refactoring (and major effort to get the code to compile) the program didn't work anymore. Some errors became obvious quite quickly with some debugging, but some turned out to be much harder. For some strange reason the `FileFilter`s kept rejecting every file that was thrown at them, for no apparent reason and as such it became necessary to start writing tests.

Now I hadn't written a single test in Haskell yet. I had heard of [QuickCheck](https://hackage.haskell.org/package/QuickCheck) but I not actually used it yet. I also knew QuickCheck wasn't the tool I needed right now. I wasn't that my software was going to go into production and I had to check for corner cases through random testing. No, I required good old fashion unit tests to see which Filter was causing the problem or whether or not it was perhaps the chaining of those filters.

So I started looking at [hspec](https://hackage.haskell.org/package/hspec). Hspec is a library designed to conceptually resemble [RSpec](http://rspec.info), a popular [Ruby](https://ruby-lang.org) testing tool, which allows you you to write very easy and comfortable to read tests, by structuring the library such that the test code itself would almost look like normal, valid, english sentences.

An example:

{% include haskell-snippet.html snippet=snippets.pathSpec %}

This code is not just nice to read, but also produces actual testing output that is easy to read AND it is also fun to write.

<pre>
<code>[function] isPathLine
<span class="green">  is true if ⍵ starts with "PATH="</span>
<span class="green">  is true if ⍵ starts with "path="</span>
<span class="green">  rejects ⍵ := {"PATH=" ∉ ⍵}</span>
<span class="green">  rejects 𝜖</span>
<span class="green">  rejects any random string containing "PATH="</span>
[function] alterMaybe
<span class="green">  alters a line matching the predicate</span>
<span class="green">  alters the first occurrence only</span>
<span class="green">  fails if the predicate matches nothing</span>
[function] addToPathLine
<span class="red">  appends a path to PATH when mode=Append FAILED [1]</span>
<span class="red">  prepends a path in PATH when mode=Prepend FAILED [2]</span>

Failures:

  1) [function] addToPathLine appends a path to PATH when mode=Append
<span class="red">       expected: "PATH=/old/path:/another:/new/path"</span>
<span class="red">        but got: "PATH=/new/path:/old/path:/another"</span>

  2) [function] addToPathLine prepends a path in PATH when mode=Prepend
<span class="red">       expected: "PATH=/new/path:/old/path:/another"</span>
<span class="red">        but got: "PATH=/old/path:/another:/new/path"</span>

Randomized with seed 847662247

Finished in 0.0131 seconds
<span class="red">10 examples, 2 failures</span>
</code>
</pre>

As a result I started writing a whole bunch of tests my project. The `Spec.hs` file is now about 180 lines long.

I put off testing in Haskell for a long time, mostly because the typechecker is so very helpful and catches a lot of errors before they even happen, but I have to say that starting using hspec was a very nice experience and I am much more inclined to test now. In fact for my newest project (a [small library](https://github.com/JustusAdam/add-to-path) for appending to PATH) I've already started writing tests as well.

There's also a package for converting test results into Jenkins friendly XML.
