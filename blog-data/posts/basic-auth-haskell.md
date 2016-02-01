## Prelude

I've recently needed to make a basic, authenticated HTTP request in Haskell, however I found it difficult to find examples and documentation on the web so I thought I'd share my findings with the world in the form of a blog post (and a [gist][]).

[gist]: https://gist.github.com/JustusAdam/9f1b3da2fadef823ff8b

First of all, in order to use http in Haskell you'll want to use the right library. Fortunately for me I already knew a library which is sort of the standard library for Haskell when it comes to http (client side). The aptly named [HTTP][] library.

[HTTP]: https://hackage.haskell.org/package/HTTP
[hackage]: https://hackage.haskell.org

The Hackage page for the [hackage][] page for the [HTTP][] library albeit being helpful does not provide very many examples on how to use it and more importantly does not provide a lot of guidance for beginners when it comes to choosing the right submodule for a particular task.

I the past I've mostly dealt with the very basic Network.HTTP package. Which is reasonably easy to understand and totally sufficient for simple, unauthenticated **GET** requests. However if you want to do more complicated things like for example auth or cookies it is too low level. For those more complicated requests you'll want to use the Network.Browser module, which seems a bit intimidating at first.

Network.Browser defines the BrowserAction Monad, which is basically IO combined with (Browser)State. All further actions are then defined on this BrowserAction.


## Browser basics

The main action with the BrowserAction Monad, outside of BrowserAction, is the `browse` function. This function evaluates the BrowserAction and returns whatever contents it is holding, very much like IO. This is the usual entry and exit point for Browser related computation in the [HTTP][] library.

The basic function for performing requests is the `request` function, which given a `Request` object performs the request, ending again inside a BrowserAction.

`Request` objects can either be created by hand, or with the utility functions from `Network.HTTP` or by using the utility functions in `Network.HTTP.Browser` itself.

The quickest one of these to get started is using the `getRequest` function from `Network.HTTP`, it just takes a `String` and returns a `Request`.

Which means a basic request starts like this

```haskell
import Network.HTTP.Browser


main =
  browse $
    request $ getRequest "http://github.com"
```

## Handling URI's

If you want to be slightly more fancy and safe with your requests, instead of using the `getRequest` function you can first parse your URI using the `Network.URI` module from the [network-uri][] package (which is what `getRequest` does internally). This module provides several ways of parsing URI's that return either Maybe's, Either's or throwing exceptions, if you're okay with throwing exceptions. But they all return `URI` type objects.

Getting those URI's into a `Request` can be done by for example `defaultGetRequest` which takes a `URI` and returns a Request that the Browser can carry out.

[network-uri]: https://hackage.haskell.org/package/network-uri

## Requests with forms

Sending requests with actual (x-www-urlencoded) payload is, as I discovered with joy, similarly easy with the Browser module. It provides a function called `formToRequest` which takes a `Form` and `URI`, returning a `Request` and a data constructor for `Form` which takes a `RequestMethod` for which the constructors are simply `POST`, `GET` etc and a list of 2-Tuples of Strings for the payload values.

```haskell
import Network.HTTP.Browser


main =
  browse $
    formToRequest $
      Form
        POST
        (fromJust $ parseURI "http://github.com/register/new")
        [ ("name", "Guido")
        , ("occupation", "Plumber")
        , ("email", "guido@python.org")
        ] 
```

## Requests with Authentication

Even though it took me a relatively long time to figure out how to do authentication with this library, it is actually relatively simple.
The BrowserAction will actually handle most of the hard authentication work for you, provided the webpage you're visiting communicates in the canonical way, using HTTP error codes.

When performing the POST or GET request with the `request` function the Browser action will check the returned status code and take action depending on the code. The two codes that are of interest are 200 (Status OK) and 401 (Unauthorized).
In case of 200 the server has computed the resource you requested and BrowserAction will simply return the body of the request. In case of 401 the server requests you to authenticate to it.

If the server requests the authentication, BrowserAction will attempt to satisfy the authentication by fetching a Username, Password combination from a generator function and sending a request for authentication to the server, retrying the original request afterwards.
The type signature for the generator function is `URI -> String -> IO (Maybe (String, String))` and by default is equivalent to `\_ _ -> return Nothing` aka there will be no authentication for any URI.
You can however set your own generator function with the `setAuthorityGen` function in the BrowserAction.

#### A few things to note about the generator function

- The two arguments provided are the full URI for the requested resource and the so called realm, which is a message the server sends to unauthorized clients.  
    Thus your generator function can return different Username, Password combinations depending on the URI.
- The generator function returns a maybe. If you don't recognize the URI that it is trying to authenticate for you don't have to provide any credentials by simply returning `Nothing`
- The return type of the generator function is an IO computation, which means you may read the credentials from a file or request them from a different server.

#### How does this look in practice?

A very simple authenticated request could look something like this.

```haskell
import Network.Browser


main =
  browse $ do
    setAuthorityGen (\_ _ -> return $ Just ("username", "password"))
    request $ getRequest "http://github.com"
```

Another version of the provider function, for multiple URI's would be by hardcoding an association list of them and fetching from the list. Like in the example below.

```haskell
import HTTP.Browser
import Control.Arrow (second)


authList = map (second (fromJust . parseURI))  -- makes the strings into URI's
  [ ("http://google.com"  , ("walter", "12.24.1975"))
  , ("http://facebook.com", ("MarkZuckerberg", "IamTheFounder"))
  , ("http://reddit.com"  , ("StephenHawking", "BlackHole"))
  ]


main =
  browse $ do
    setAuthorityGen (const . return . flip lookup authList)
    request $ getRequest "http://github.com"

```


## Sending literal JSON

I've also recently had the pleasure to be in a situation where I've wanted to create some very simple json, for which the proper way (via the [aeson][] library) would have felt like overkill,

I wanted to create the output with just string concatenation and then send it to the client. Unfortunately the [warp][] library, which is sort of the standard web server library for Haskell, uses ByteStrings for output. Now if you do things the canonical way, the [aeson][] way it'll create a unicode encoded ByteString for you and there's nothing to worry about.

The JSON standard requires the text to be unicode encoded. However when using string literals and concatenation it becomes quite obvious that ByteString is inherently not meant for unicode. So in order to get a Unicode encoded String you'll have create `Text` rather than a `String` and then specifically encode it as a unicode ByteString. You can do this by importing the `Data.Text.Encoding` module or the `Data.Text.Lazy.Encoding` module if you, like me, are dealing with [warp][] and need a lazy ByteString for output and then simply use the `encodeUtf8` function on your `Text`.

[warp]: https://hackage.haskell.org/package/warp
[aeson]: https://hackage.haskell.org/package/aeson

```haskell
{-# LANGUAGE OverloadedStrings #-}

import Data.Text.Lazy
import Data.Text.Lazy.Encoding
import Network.Warp


warpApplication respond request =
  respond $ respondLBS $ encodeUtf8 "{\"text\": \"My json response\"}"


main = run warpApplication
```
