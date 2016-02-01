Building Haskell code on [travis][] is a bit complicated. Haskell happens to be one of the less well supported languages on [travis][].

[Travis][travis] ships with an older version of ghc (I think its 7.8) and cabal. But many projects either rely on newer versions of ghc, such as [elm-init][] or want to be compatible with older ghc, such as [ja-base-extra][]. This requires building with either a different version of ghc or multiple ghc/base library versions.

[elm-init]: https://github.com/JustusAdam/elm-init
[ja-base-extra]: https://github.com/JustusAdam/ja-base-extra
[travis]: https://travis-ci.org

There's a wonderful project by a github user named @hvr. The project itself is called [multi-ghc-travis][] and provides an example [.travis.yml][example-travis-yml] which configures a matrix of build environments for travis based on as many ghc and cabal versions as you require by manually downloading and installing the necessary ghc ppa's on the build VM.

[multi-ghc-travis]: https://github.com/hvr/multi-ghc-travis
[example-travis-yml]: https://github.com/hvr/multi-ghc-travis/blob/master/.travis.yml

This is great and all, however bears a downside as it requires root privileges in the VM to add ppa's and install packages, which prohibits use of the new and faster, container based travis architecture.

There has been some nice development in container customization lately and as a result there's now a container compatible way of customizing your Haskell build environment on travis as this [section][container-readme-section] of the [README][multi-ghc-travis] shows.

[container-readme-section]: https://github.com/hvr/multi-ghc-travis#travisyml-for-container-based-infrastructure

The even nicer thing is that the repository also provides you with a Haskell script that automatically creates the new-style .travis.yml from your **tested-with** section in your **.cabal** file. Simply provide the script with a **.cabal** file and pipe the output into a file called .travis.yml and you're pretty much set.

Now I found it rather difficult to find information on how the **tested-with** section in a **.cabal** file should look. The [cabal documentation][cabal-doc] simply states that it contain *list compiler*.

[cabal-doc]: https://www.haskell.org/cabal/users-guide/developing-packages.html#package-properties

Searching further I found that *compiler* is supposed to be the short name of a compiler, such as *ghc* version bounds for that compiler. Those version bounds are very similar to those of dependencies. Resulting in a field which looks something like this:


    tested-with:
        GHC >= 7.0 && < 7.10,
        LHC >= 0.6 && < 0.8

That's all I've got for now. If you've got something to add [catch me on twitter][twitter].

[twitter]: https://twitter.com/justusadam_
