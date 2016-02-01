{% assign snippets = site.data.snippets.monkey_patching %}

*Hint: all python examples here run on python 3 and you can try them for yourself and experiment.
The source can be found [here]({{ site.snippet_base_url }}/snippets/python/monkey-patching)*

As everyone probably knows most objects in python are not static as static as in many other languages. When you create a class you can specify class attributes in the class body and instance attributes in the init method.

{% include python-snippet.html snippet=snippets.attribute_basics %}


However that is by no means final.

## Patching objects

Even though you are encouraged to declare instance attributes in the initializer you are by no means required to do so. You can declare/assign instance attribute in any method and even outside the class at any point in the program.

{% include python-snippet.html snippet=snippets.attributes_from_outside %}

As you can see we can add attributes from inside another method. You can also remove the attributes from anywhere.

### Some things to learn from this

Declare your instance attributes in the initializer because you are guaranteed that this method will execute, or you probably will run into unexpected AttributeErrors somewhere down the line. Even initializing them with `None` is better than not initializing at all.

Never add instance attributes from the outside. You may accidentally overwrite others or forget to do it and that would again cause name errors.

### Exceptions from the rule

There are however some exceptions. For instance if you use a decorator to attach meta information to a function or class. It is okay to do here, because, again, you are guaranteed that the function is going to execute.

{% include python-snippet.html snippet=snippets.python_meta_information_decorator %}


*Note that we're attaching instance variables to a function. Functions are just objects, like anything else, so we're allowed to do that*

### How it works

Objects in python are actually quite a simple construct.

For purposes of this article we can just think of objects as a combination of a class, the type of the object, and a so called instance dict.

The class, or type, is what we created when we were using the `class` keyword and it contains the methods and class attributes and reference to parent classes and so on.

The instance dict is a simple python dictionary that holds the instance variables.

When an python object is created by the runtime the instance dict is actually empty[^instance_dict_init], no object actually has any instance attributes[^slots], until the `__init__` method is called. In the init method we are basically monkey patching in our instance attributes. This sets the key corresponding to the name of the attribute in the instance dict.

[^instance_dict_init]:
    This is true for any custom object. It can however be changed by using decorators or metaclasses.

[^slots]:
    This is true for classes that do not define `__slots__` which will in fact allocate named fields.

{% include python-snippet.html snippet=snippets.instance_dict_basic %}

## Patching classes

As you may have guessed already, if we're allowed to attach attributes to a function, we are also allowed to attach attributes to a class.

There are two ways for obtaining the class from an object.

{% include python-snippet.html snippet=snippets.get_class %}

I personally prefer directly referring to `__class__` if I'm about to tamper with it, but either one works fine.

Now we can add/remove our class attributes.

{% include python-snippet.html snippet=snippets.alter_class_attributes %}

### How it works

In python classes are just object. Instances of `type`. And like most objects their attributes can be freely modified, removed or added.[^class_temper_limits] They do have an instance dict `__dict__` as well, however in this case it is not a vanilla python `dict` but rather a `mappingproxy` object. This is the interface the pytho interpreter shows for the instance dicts of lots of builtin types and objects, and this particular dict-like structure can **not** be modified directly. `__setattr__` and `__delattr__` however work on (most) types.

[^class_temper_limits]:
    This pretty much only applies to classes actually created using `class`, not to builtin types such as for example `object`, `function` and `type` itself.

## The fun stuff - advanced class patching

We've just learned that we can patch classes in python by modifying its instance dict, which contains the class attributes. You may be guessing it already, or you may have seen it, the instance dict of a class does not only contains the attributes but it also the methods that are defined on the class.

Furthermore if you print one such method the output says the type is `function`, not `method`.

In fact python does not have `methods` per se. Instead there are functions contained in a classes instance dict. When you have an instance of the class and you print the method referencing from the instance you'll notice that the type changes from `function` to `bound method`.

{% include python-snippet.html snippet=snippets.functions_and_methods %}

Bound methods are basically partially applied functions, where the first argument is the object the method has been called on.

As we can also see on line 25 a method can be called on the class directly which in which case you will have to provide the `self` argument yourself, what the type of that `self` argument is, is irrelevant, and not checked anywhere (by the language).

Since methods are just functions until called, we can make the assumption, that they are in fact class attributes that happen to be callable. And in fact if you look at Python classes that is exactly the case. As a practical result of methods being nothing but class attributes and class instance dict being modifiable we can begin to assume that perhaps methods can be modified in just the same way.

Let's see how it works:

{% include python-snippet.html snippet=snippets.method_reassignment %}[^new_inst_meth]

[^new_inst_meth]:
    The added/reassigned/removed methods affect both new and old instances of the class (instantly).

*Do remember that you have to add methods __to the class__, not the instance/object.*

Now please note that this is highly unsafe practice. Technically you can remove pretty much any method from any object and it is very hard to find where and if that has been done.

There is some fun stuff you can do now, since the methods you declared yourself are not the only thing you can change. This is an example of how you can overwrite `__init__` to change the behaviour of a class during object instantiation.

{% include python-snippet.html snippet=snippets.hacking_init %}

However you do not have to stop there.

Those that know how decorators work will be aware that they are just normal python functions and can be used as such.

{% include python-snippet.html snippet=snippets.quick_decorator %}

We can use that fact to dynamically create classmethods and staticmethods.

{% include python-snippet.html snippet=snippets.dynamic_static_classmethods %}

I can actually think of very few ways that this can be useful. You should of course not apply this to live objects, since the consequences are highly opaque.

One way of using this though is to take a bunch of classes and add common or dynamically constructed methods to them.

The following is an example of a decorator that can be applied to a class and if there are public class variable in the class, whose value is a type, it will remove them and dynamically construct an `__init__` method for the class which requires the names of those fields as keyword arguments, typechecks them and then adds them to the object.

We can easily construct this and then add this new `__init__` method to our class.

{% include python-snippet.html snippet=snippets.dynamic_init %}

You could just as easily add more to this decorator. The fields it adds could be private by default and it could also add dynamic accessor methods. Instead of just writing types to the class attributes, you could provide further meta information and construct appropriate accessor methods or even not create fields at all and instead create field mimicking accessor methods using `@property`. This can be very useful if your object is tying to hide (or simplify) access to a database or external system by imitating a normal object but instead of accessing fields it may make a database or network connection or read from a file.   

All in all it is I think useful to know that these things are possible, and if used correctly certainly can be a powerful tool. I like the possibilities but I also have never really used it in practice.

Let me know if you'd be interested to see more 'useful' application of this concept and I might make another post about it.
