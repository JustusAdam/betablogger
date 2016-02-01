---
author: Justus
title: Only if I know myself - recursion
---

## Preface

I think a lot of the confusion that arises when new programmers learn recursion, is that it is often not taught step-by-step, like iteration is, but prefixed with 'we are learning recursion now', a word which will mean little to any non-programmer.

Let's instead look at it step by step and with many examples to better illustrate what it does and how. In the following examples it is very helpful if we think of a function not as a piece of code that does something, but more as an almost mathematical expression which takes some inputs and calculates some new value.

First we'll look at a simple problem.

## Faculty

We'd like to calculate the faculty of any natural number. We'll assume our input is always positive.

{% highlight haskell %}
faculty 0 = 1
faculty 2 = 2
faculty 4 = 24
{% endhighlight %}

Now we know that just making a list like this and defining faculty for all numbers is not going to work since there are infinitely many natural numbers, and an infinite list or function does not fit into a computers memory. So we need to find some generic way of calculating this value. Fortunately the faculty has the a very nice property that exempt 0 any faculty `n!` is equal to the value `n` times the faculty of its predecessor, aka `n! = n * (n-1)!`.

This property is very nicely illustrated by just making a list of expressions calculating sequential faculties:

{% highlight haskell %}
faculty 1 = 1                 = 1
faculty 2 = 1 * 2             = 2
faculty 3 = 1 * 2 * 3         = 12
faculty 4 = 1 * 2 * 3 * 4     = 24
faculty 5 = 1 * 2 * 3 * 4 * 5 = 120
{% endhighlight %}

Well, lets write that more general in code.

{% highlight haskell %}
faculty n = n * faculty (n - 1)
{% endhighlight %}

Great. This actually looks quite similar to the mathematical expression `n! = n * (n-1)!` we've had before. But we're not done yet. What about 1? What about 0?

Well, the faculty of 0 is 1. We all know that because it is simply defined as 1. And the faculty of 1 is also safe, because if `0!` is defined as `1` then `1! = 1 * 0! = 1 * 1 = 1`. Great. But our function doesn't reflect that. In it's current form it would try to calculate `0!` by doing `0 * (-1)!` but that is wrong, `(-1)!` is not defined. Even worse, it would try to calculate `(-1)!` as `-1 * (-2)!` and then `(-2)! = -2 * (-3)!` and so on, all the way to negative infinity. We cannot let that happen.

So how do we stop it? We simple define the faculty of 0 to be 1.

{% highlight haskell %}
faculty 0 = 1
faculty n = n * faculty (n - 1)
{% endhighlight %}

And this will make sure we have an anchor point. A fixed point to our computation that makes sure it will eventually terminate.

We do this above our original definition so that it will be checked first.

Finally we'll just add a type signature to make it easier on people to understand what we are doing.

{% highlight haskell %}
faculty :: Int -> Int
faculty 0 = 1
faculty n = n * faculty (n - 1)
{% endhighlight %}

Another example.


## Fibonacci numbers

This one is trickier, because every step of the way we need to know **two** of our predecessors.

We'll try two different approaches, one is the top-down approach, one is the bottom-up approach.

### From the top

This is the more naive approach, but very easy to understand.

Lets first look at what a fibonacci number is. Any n'th fibonacci number is defined as the sum of its first and second predecessor, aka `f(n) = f(n-1) + f(n-2).` In code it would look something like this:

{% highlight haskell %}
fibonacci n = fibonacci (n - 1) + fibonacci (n - 2)
{% endhighlight %}

Easy enough. But now we run into the same problem we've had before where it would eventually run off to negative infinity `f(2) = f(1) + f(0)` and then `f(0) = f(-1) + f(-2)`, a very undesirable situation.

So we need a base case. Let's define `f(0)` to be `1`. Because we know that the first number in the fibonacci series is `1`.[^starting_fibonacci]

[^starting_fibonacci]:
    You can start the series at 1 as well which will produce a similar result to a index 1 based fibonacci series.

{% highlight haskell %}
fibonacci 0 = 1
fibonacci n = fibonacci (n - 1) + fibonacci (n - 2)
{% endhighlight %}

Now `f(0) = 1` and `f(1) = f(0) + f(-1)` and ... wait ... `f(-1)`? Something is wrong. If `f(1)` needs the result of `f(-1)` then something must be wrong with `f(1)` and indeed it is. As you may recall from the fibonacci series the first **two** numbers are both defined as `1`, this is because if we need two numbers to calculate the next number in the series we need at least two anchor points to calculate the third value. So let's add that to our code as well.

{% highlight haskell %}
fibonacci 0 = 1
fibonacci 1 = 1
fibonacci n = fibonacci (n - 1) + fibonacci (n - 2)
{% endhighlight %}

Now we can calculate

{% highlight haskell %}
fibonacci 1 = 1
fibonacci 2 = fibonacci 1 + fibonacci 0 = 1 + 1 = 2
fibonacci 3 = fibonacci 2 + fibonacci 1
            = (fibonacci 1 + fibonacci 0) + 1
            = (1 + 1) + 1
            = 3
{% endhighlight %}

and so on, for all natural numbers.

*Note: We have created a zero indexed fibonacci series (it starts with 0) if you want a one based series (starting with index 1) then define `fibonacci 1` as `1` and `fibonacci 2` as `1` as well.*

And there's our finished function.

{% highlight haskell %}
fibonacci :: Int -> Int
fibonacci 0 = 1
fibonacci 1 = 1
fibonacci n = fibonacci (n - 1) + fibonacci (n - 2)
{% endhighlight %}

As you can see this function is doubly recursive (if calls itself twice) which is bad for some compiler optimizers. We can write a different version of it that only uses a single recursion.

## Bottom up

This one is a bit more involved.

For the singly recursive function we start again with a definition.

{% highlight haskell %}
fibonacci n =
{% endhighlight %}

But now instead of calculating our predecessors we'll start calculating the next fibonacci number, starting with 0. We do this by assuming we get passed the two predecessors (because we need that to calculate) and then pass them on to the next calculation step. We'll need an extra function for it, and I will call it `fibonacciHelper` that takes the two predecessors, out target value `n`, and an index for the current value.

{% highlight haskell %}
fibonacciHelper pred1 pred2 index n = fibonacciHelper (pred1 + pred2) pred1 (index + 1) n
{% endhighlight %}

Now we need some condition for termination, which we'll do by checking whether our index is equal to the target value `n`.

{% highlight haskell %}
fibonacciHelper pred1 pred2 index n
  | index == n = thisNumber
  | otherwise  = fibonacciHelper thisNumber pred1 (index + 1) n
  where
    thisNumber = pred1 + pred2

-- some people may prefer this notation

fibonacciHelper pred1 pred2 index n =
  let
    thisNumber = pred1 + pred2
  in
    if index == n
      then thisNumber
      else fibonacciHelper thisNumber pred1 (index + 1) n
{% endhighlight %}

Once we have this helper function, all that is left to do is to cover the two base cases again


{% highlight haskell %}
fibonacci 0 = 1
fibonacci 1 = 1
{% endhighlight %}

and call the helper function with the appropriate initialization.

{% highlight haskell %}
fibonacci 0 = 1
fibonacci 1 = 1
fibonacci n = fibonacciHelper 1 1 2 n
{% endhighlight %}

Now you may ask why start with index `2` instead of `0` or `1`. Well, if we consider the call to `fibonacciHelper` with `pred1 = 1` and `pred2 = 1` then `thisNumber` is `2` which is what we'd expect to get as the third fibonacci number (fibonacci number with the index `2`).
