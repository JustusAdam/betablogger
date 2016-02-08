So the [Jekyll](//jekyllrb.com) default installation using `jekyll new` is, albeit beautiful, a little bit bare bones, which is probably deliberate.

## Adding a sidebar

Mostly I felt like there was a lot of unused space on the index page, so I started to customize the index.html and added a `sidebar-right.html` file to include in the index page (modular is always good).

```html
<div class="sidebar-right sidebar"></div>
```

And I added some content in the form of short FAQ-like messages titled "Did you know ...".

```html
<div class="sidebar-right sidebar right column-4">
  <p>Did you know ...</p>
  <ul class="fact-list smaller">
    ...
  </ul>
</div>
```

But I wasn't satisfied. There were a lot of big and ugly `<a>` tags in there  and the whole thing felt so ... static. Actually writing a `<ul>` element by hand in html felt just ... wrong. Fortunately I had just learnt about [jekyll collections](https://jekyllrb.com/docs/collections/) and was using them to create some [project pages](/projects/). So I created a new collection called 'quick_facts' and refactored the messages into individual `.md`'s containing markdown source for the messages, plus the YAML Front Matter and added this little line instead of the giant blobs of text from before.

```html
<ul class="fact-list smaller">
  {% for fact in site.quick_facts %}

    <li{% if forloop.last %} class="last"{% endif %}>{{ fact.output }}</li>

  {% endfor %}
</ul>
```

The `if forloop.last` block adds a 'last' class to the last element to allow me to add some pretty separators using `border-bottom`.

Now if I want to edit a message, instead of digging around in lines upon lines of raw html code I can go straight to the message file containing some nice markdown source.
The best feature in my eyes though is that if I want to add, replace or delete I just have to add/replace/delete `.md` files in the `_quick_facts` directory and it'll process them automatically.

## Displaying excerpts and descriptions

On the website I've had before I was using [Drupal](//drupal.org) which by default displayed a kind of teaser on the overviews. I liked that so I replicated it in Jekyll.

But I wanted to do more, or more precisely I didn't realize at first that Jekyll offers an `excerpt` attribute on he document objects and so I added something of my own making.


```html
{% if post.description %}
<p class="small light-font">
  {{ post.description | truncate: 100, '...' }}
</p>
```

Which would, if a document object had a `description` attribute print the first 100 characters of it in a smaller, lighter font.

However I discovered that the document objects actually have an `excerpt` attribute which will generate a teaser based on the content itself, so I combined the two. Furthermore I found out that you can simply add your own custom variables to the `_config.yml` which will then be available via the `site` attribute, so I refactored the teaser length such that it is set in the main config as `quick_view_length`. And here's the final result:

```html
{% if post.description %}
  {% assign desc = post.description %}
{% else %}
  {% assign desc = post.excerpt | remove: '<p>' | remove: '</p>' %}
{% endif %}
  <p class="small light-font">
    {{ desc | truncate: site.quick_view_length, '...' }}
  </p>
```

Now it will either print the first paragraph of the page (jekyll's default `excerpt` style) or a custom description, if you provide one, perhaps if the first paragraph is not very representative of the rest of the content.

You can check out how it looks on the [homepage](/).
