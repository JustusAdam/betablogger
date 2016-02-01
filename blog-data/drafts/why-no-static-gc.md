---
title: One reason Haskell needs a runtime.
author: Justus
---

{% highlight haskell %}
f =
  let
    l = [0..100]
  in
    l !! 6
{% endhighlight %}

Which part of the list can I clean up?
