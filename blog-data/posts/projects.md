So I have this idea ...

On the old page I used to have not only my blog but also an ordered collection of pages dedicated to the projects I was currently working on or had finished.

I feel like I should do that again but a little bit different this time. So here's what I'm thinking: most of my projects are hosted on [GitHub](//github.com) now and because I can easily add github pages to any project it doesn't make a whole lot of sense to add some kind of documentation to the projects on this site specifically.
BUT what I think might be good is more of a personal approach to the project. Why I started it, how I feel about the tools used and the progress it has made.

Fortunately Jekyll offers custom collections so it shouldn't be too hard to write an overview page and get all the pages nice and organized.


Later ...

Well, it seems I kind of forgot to publish this and started woking on the projects subdirectory already. It is kind of finished and working now. the basic features I wanted are now in place. I'll probably expand and extend it later.

### How I did it:

I made a `_projects` directory, added the files with some custom variables, such as `github_link`, `status` and later `languages` to the 'YAML Front Matter' and mapped it to the '/projects/' path.
Then I added a custom template for the projects (project.html) where I took a lot of inspiration from the 'post' template but I added output for my custom variables into the page header.
And finally I created a 'projects.html' page for an overview of all subpages, which is surprisingly easy with the liquid [templating language](//github.com/Shopify/liquid) showing mostly the titles and links to the actual pages plus some metadata.
