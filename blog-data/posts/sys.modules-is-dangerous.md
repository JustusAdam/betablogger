So I am sitting here watching [David Beazley](//twitter.com/dabeaz)'s [pycon talk](//https://www.youtube.com/watch?v=0oTh1CXRaQ0) about modules, packages and imports and he is talking about `sys.modules` sort of guarding multiple imports which inspired me to fire up the python interpreter myself and start messing about.

## Reimporting in Python - Basics

As David mentions, in python you cannot just `import module` again to reload the module. The canonical albeit still bad way is to `import importlib` and use `importlib.reload(module)`.

I'd like to take this opportunity to disclaim here immediately and sort of spoil the conclusion by stating that you should absolutely avoid reimporting any modules in python. As you'll see towards the end, things can get very messy very quickly when you reimport modules. It can cause severe bugs which can be virtually impossible to track down.

If you find yourself playing with the idea of reimporting modules in software that'll be used productively consider alternatives such as writing unittests (if you're using it to test code while developing), using multi-/subprocess to run the code in a separate interpreter, refactoring or simply restarting the interpreter.

Also in this article I deliberately try to make programs fail and break which is intended to explore features of the interpreter and standard library and not meant to be done in productive software.

## Messing with `sys.modules`

David Beazley also mentions in his talk that the instance actually recording imported modules is located in `sys.modules` which happens to be a standard python dict.

The interesting thing about that is that unlike `mappingproxy` which is the dict-like object/wrapper/imitator that a lot of the builtin data structures (such as the `dict` itself) use to imitate a dict while avoiding modification and infinite recursion this `sys.modules` standard dict supports item assignment `__setitem__` as well as deletion `__delitem__`.

**Note:** `dict.__dict__.__getitem__ = 8` results in `AttributeError: 'mappingproxy' object attribute '__getitem__' is read-only`

**Note:** Otherwise any `dict` would have an instance dict `dict.__dict__` which would have an instance dict `dict.__dict.__.__dict__` of type dict which would have an instance dict and so on.

This got me thinking "How much does the sys.modules dict actually influence the import process." and as it turns out a lot and it allows you to mess with it.

If you import a module, let's call it `test`, modify the file and import again (in the same interpreter instance) nothing changes, you're still running the old code. But what happens if you delete the module from sys.modules first?

The answer: nothing at first. The code still runs, all functions that were in the module previously are still there, as is the module itself, __but__ something odd happens if you execute `import test` again: it reimports the module.

```python
# module test

def hello():
    print('hello everyone')

# in the interpreter
>>> import test
>>> test.hello()
hello everyone

# change the file
def hello():
   print('hello')

# back in the interpreter
>>> import sys
>>> del sys.modules['test']  # delete 'test'
>>> 'test' in sys.modules
False

>>> import test  # reimport
>>> test.hello()  # and voila, new an shiny
hello

```

The reason why calling `foo.hello` refers to the new code instead of the old one, is because `import` overwrites it's value in our current `globals()` dict when we use it. As such it reloads the module for whatever namespace we happened to be in.

## Consequences

This is would per se not be all that bad, __however__ this hacked reload does not facilitate the same behaviour as `importlib.reload`.

The difference between reloading the module this way, which I do not recommend anyone actually does, and using `importlib.reload` is that this particular way of reloading only reloads the module in the current namespace.

Let's suppose we have two modules `foo.py` and `bar.py` where `bar` imports `foo` and uses a function defined therein:

```python
# foo.py

def hello():
    print('hello')

# bar.py

import foo

def hello_bar():
    foo.hello()

```

We can then do the following experiment:

```python

>>> import foo, bar
>>> bar.hello_bar()
hello
>>> foo.hello()
hello
# now we go into foo.py and change print('hello') to print('hello everyone')
>>> from importlib import reload
>>> reload(foo)
>>> bar.hello_bar()
hello everyone
>>> foo.hello()
hello everyone

```

As you can see using `importlib.reload` reloads the module and references to the module are updated as well. This behavior is different if you reload using our dirty little trick.


This does not work if you reassign contents of the imported module. I you do something like `var = module.other_var` change the value of `other_var` and reload `var` will still have the old value. That applies to functions and variables as well as `from module import symbol` imports.
From this I can only assume that `importlib.reload` changes the module object in place rather than replace it.


```python

>>> import foo, bar
>>> bar.hello_bar()
hello
>>> foo.hello()
hello
# now we go into foo.py and change print('hello') to print('hello everyone')
>>> import sys
>>> del sys.modules['foo']
>>> import foo
>>> bar.hello_bar()
hello
>>> foo.hello()
hello everyone

```

Here the reference to `foo` in `bar` is not being updated which seems to indicate that this `import` is overwriting the definition of the module wherever it is being kept and the old version of the code remains in the `globals()` dicts of the modules using it.

## What is `sys.modules`?

As we have seen deleting entries in `sys.modules` causes the interpreter to reload modules in `import` statements, but why is that and what are the entries in `sys.modules`?

Well, `sys.modules` contains references to already imported modules. You can query it on the type of the entries and it tells you that the entries are actual modules, the same class/type you'd obtain when querying the module directly.

```python

>>> import foo
>>> import sys
>>> type(sys.modules['foo'])
<class 'module'>
>>> type(foo)
<class 'module'>
>>> type(foo) == type(sys.modules['foo'])
True

```

In fact the module reference in `sys.modules` is the the exact same object as your module itself.

```python

>>> sys.modules['foo'] == foo
True
>>> sys.modules['foo'] is foo
True

```

Knowing all this, here is a very crude sketch of how the `__import__` function in python works which is the implementation of the `import` statement.

```python

import sys

def __import__(name, globals=None, locals=None, fromlist=(), level=0):
    # we wont care about how globals, locals, fromlist and level are used
    # it is not important, but if you're interested refer to
    # help(__import__) to get started

    if not name in sys.modules:
        return sys.modules[name] = do_actual_import(name, ...)

    return sys.modules[name]

```

This, again, is not the actual implementation of the `__import__` function but rather a __very__ crude approximation for the purposes of this article. For instance this function could not deal at all with importing submodules, such as `foo.bar`

Now if we were to delete the entry from `sys.modules` `__import__` would do the expensive import of the file again, since it cannot find the module in `sys.modules`. It then returns the new module and adds the reference to `sys.modules` which then would also point to the new module, however any module that imported `name` previously still has a reference to the module object in its `globals()` (or `__dict__` if you prefer) dict and as such runs the old code.

As for the behavior of `importlib.reload`, it reloads the module back into the original `module` object and 'fixes' (though 'changes' might be the better term to use here) the references in-place.[^5] As a result any module that imported using `import module` and then uses `module.attribute` or `module.function()` instead of reassigning with `from module import attribute` or `myattribute = module.attribute` will now have the updated, reimported version of the code.[^6]

[^5]:
    Which you can actually do yourself. `module` objects are not immutable and you can freely assign, remove or alter any part of it `module.foo = 0` or `module.bar = lambda k: print(k)`

[^6]:
    The same rules apply to if you've altered the module `module.attribute = "new value"` or `module.function = lambda a: print(a, "hello")`, only modules importing the base module `import module` will have updated refs `module.attribute ==> "new value"`, not modules using `from module import attribute` or `myattr = module.attribute ==> myattr == "only value"`

What it doesn't do however is remove any keys. This means if you imported a module `bar` with a function `hello` and you were to edit the file, removing the function entirely or commenting it out and then reimport the module using `importlib.reload` the new module object `bar` still has the `hello` attribute with the original function in it.

```python

>>> import foo, bar
>>> bar.hello()
hello
# at this point I removed 'hello' from bar.py
>>> import importlib
>>> importlib.reload(bar)
<module 'bar' from '/Users/justusadam/projects/Python/misc_python/bar.py'>
>>> bar.hello()
hello
>>>

```

## Conclusions

What should one take away from it? Don't reimport modules.

It does not matter whether you use `importlib.reload` or something worse, unless you know exactly what you're doing and act very cautiously you're very likely to end up with code in a state, where some parts of the program have older and some parts have newer references to the code and there's no way for you to predict the outcome of a particular computation. Write unittests instead.

However if you feel pathologically adventurous or absolutely require dynamic reloads, try to only keep references to the top level modules and reload them individually using `importlib`.



Good luck, have fun and remember that `collections` is worth a look and use `yield`, it's awesome.


## Fun facts and extras

#### What happens with `importlib.reload` when you delete the module from `sys.modules`?
It fails. In order to reload the module it must be in `sys.modules`.

```python

>>> del sys.modules['bar']
>>> 'bar' in sys.modules
False
>>> importlib.reload(bar)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/Cellar/python3/3.4.3/Frameworks/Python.framework/Versions/3.4/lib/python3.4/importlib/__init__.py", line 130, in reload
    raise ImportError(msg.format(name), name=name)
ImportError: module bar not in sys.modules

```

The same applies if you reassign `sys.modules['bar'] = foo`. You'll get the exact same error.

#### My crude implementation of `importlib.reload`

```python

def reload(module):
    file_name = module.__file__

    with open(file_name) as file:
        raw = file.read().decode()

    m_globals = {}

    exec(raw, globals=m_globals)

    for symbol, val in m_globals.items():
        module.__dict__[symbol] = val

    return module

```

Again, this is not the official implementation and strongly simplified. It also does not interact with `sys.modules`, which we know it should/does, and it again only works for top-level modules. It is only here to illustrate how some of the behavior of the function could be implemented in python not how it is actually done.
