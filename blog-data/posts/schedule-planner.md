# The News (TLDR)

Today I worked out the last (major, known to me) kink of my schedule-planner web-app.

It is [live right now](http://justus.science/schedule-planner-web/) (and should work as expected).

Feel free to try it and find bugs. I challenge you :D .

The Website is written in [Elm](http://elm-lang.org), the (Elm) source can be found on [GitHub](https://github.com/JustusAdam/schedule-planner-web). The page itself is deployed on [GitHub Pages](https://pages.github.com).

The actual work is done by the backend server which is pure [Haskell](https://haskell.org), deployed on [Uberspace](http://uberspace.de). And the source is available on [GitHub](https://github.com/JustusAdam/schedule-planner) as well.

## What it does

schedule-planner is an application that, given a list of lessons and a list of rules, calculates the perfect layout for those lessons that adheres to the given rules as much as possible.

Currently you can define rules that select either days, timeslots or specific cells (specific timeslot on a specific day) and then assign a weight to it. The higher the weight, the more reluctant the algorithm will be to allocate lessons in that day/slot/cell.

The application is usable from the command line as a simple tool that takes a json file as input and either prints the result schedules to the command line or emits new json containing the resulting schedules.

The website is a convenient way of inputting the lessons and rules. Also it'll save your input in the browser, so nothing gets lost when you close the browser or reload.

There is lots I'd like to improve abut the interface and more features I'd like to add to the algorithm, but that'll have to wait.

## The last kink

... I faced was a ting called CORS, or cross origin resource sharing, or rather the lack of it by default. During the last year or so I have come in contact with many free services on the internet providing things like [online IDE's](https://c9.io), [codesharing](http://hastebin.com), [source code hosting](https://github.com) and [project website hosting](https://pages.github.com) to name a few.
GitHub is a service I am using constantly and recently I started also using GitHub pages a lot more, so I wanted to take advantage of the easy deployment via git on [GitHub pages](https://pages.github.com) for this project as well. But since GitHub pages can only host static websites (and markdown), it could not run the Haskell server I am using as backend. So I put the webpage on github pages and deployed a static binary of the backend server, that does only the calculation, on my VM on [Uberspace](http://uberspace.de). This has the added benefit that GitHub pages now takes care of serving the html and relatively large javascript files, while the backend server only deals with a small amount of json for in- and output. This takes some load away from Uberspace.

As a result of having the website on GitHub and the calculation server on Uberspace, the domains for them are different. As a result most modern browsers will reject those communication between the two by default. Unless one sets a set of so called CORS headers, and it took me a while to do that properly.

At first I tried to do it by hand, just have the server emit the necessary headers all the time. That unfortunatley did not seem to work, so I tried adding a Haskell library to deal with CORS on the server side, which did not work either. For some reason the server middleware rejected the request outright, I can only assume it decided the requests the rowser was sending did not fulfill the expected CORS protocol.

Even though adding the Library did not fix my problem, it thought me more about what CORS headers were there and how did they work. So when finally, in frustration, I turned back to the original idea of static headers, I could figure out which three headers were actually required (one of which I had forgotten before). Adding them to the request seems to do the trick now.

This does not make the site or your browser vulnerable, as far as I can tell, there's no reason to worry. Just try it and have some fun.

## Licensing

Both projects have an open source license (LGPL v3). Feel free to use the code as you'd like, I'd appreciate it if you'd contribute, should you have ideas for improvement/be interested in advancing the project.
