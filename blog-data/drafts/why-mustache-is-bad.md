---
title: Why mustache is bad
author: Justus
---

I've recently implemented a parser and library for the mustache template language and I have found some problems with it.

Now I have to disclaim here that the title s somewhat of a mere teaser for sensationalism. I actually have few problems with the template syntax itself.

Mustache is actually a relatively nice template language, for it has few, simple rules which encompass the most useful set of actions which can be taken on template and data.

## Mustache itself

As a quick reminder of what the syntax actually specifies: there are simple **variables** written like so `{{ variable_name }}`,  **conditionals** in the form of sections, where `{{# section }}` is the beginning of the section and `{{/ section }}` is the end of the section, iteration, also via section `{{# iterable }} ... {{/ iterable }}` inverted conditionals `{{}}`
