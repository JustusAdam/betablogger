*Hint: all python examples here run on python 3 and you can try them for yourself and experiment.*

As everyone probably knows most objects in python are not static as static as in many other languages. When you create a class you can specify class attributes in the class body and instance attributes in the init method.

```python
#! /usr/bin/env python3

class TestClass:

    # class atttributes are declared in the class body
    # they absolutey must be assigned a value
    class_foo = 0
    class_bar = object

    def __init__(self):

        # instance attributes are assigned to the object in the initializer
        # these also need to be assigned a value
        self.instance_foo = 8
        self.instance_bar = None
```


However that is by no means final.

## Patching objects

Even though you are encouraged to declare instance attributes in the initializer you are by no means required to do so. You can declare/assign instance attribute in any method and even outside the class at any point in the program.

```python
#! /usr/bin/env python3

class TestClass:

    def __init__(self):
        pass

    def method_1(self):
        # defining an instance attribute from inside another method
        self.instance_foo = 4



my_instance = TestClass()

print(
    hasattr(my_instance, 'instance_foo')
)  # =>>  False
# the instance_foo attribute does not exist yet

my_instance.method_1()

print(
    my_instance.instance_foo
)  # =>> 4
# now it does

print(
    hasattr(my_instance, 'instance_bar')
)  # =>> False

my_instance.instance_bar = 'hello'

print(
    my_instance.instance_bar
)  # =>> hello

del my_instance.instance_foo

my_instance.instance_foo
# =>> AttributeError: 'TestClass' object has no attribute 'instance_foo'
# trying to call non-existing attributes causes an AttributeError
```

As you can see we can add attributes from inside another method. You can also remove the attributes from anywhere.

### Some things to learn from this

Declare your instance attributes in the initializer because you are guaranteed that this method will execute, or you probably will run into unexpected AttributeErrors somewhere down the line. Even initializing them with `None` is better than not initializing at all.

Never add instance attributes from the outside. You may accidentally overwrite others or forget to do it and that would again cause name errors.

### Exceptions from the rule

There are however some exceptions. For instance if you use a decorator to attach meta information to a function or class. It is okay to do here, because, again, you are guaranteed that the function is going to execute.

```python
#! /usr/bin/env python3

def attach_meta(**arguments):

    def _inner(function_or_class):

        if hasattr(function_or_class, '_meta'):
            raise AttributeError('Function already has meta information')
        else:
            function_or_class._meta = arguments
        return function_or_class
    return _inner


def print_with(obj):

    if 'foo' in obj._meta:
        print(obj, 'printed with', obj._meta['foo'])
    else:
        print(obj)


@attach_meta(foo='blue')
def my_func():
    pass


print_with(my_func)
# =>> <function my_func at ...> printed with blue

```

*Note that we're attaching instance variables to a function. Functions are just objects, like anything else, so we're allowed to do that*

### How it works

Objects in python are actually quite a simple construct.

For purposes of this article we can just think of objects as a combination of a class, the type of the object, and a so called instance dict.

The class, or type, is what we created when we were using the `class` keyword and it contains the methods and class attributes and reference to parent classes and so on.

The instance dict is a simple python dictionary that holds the instance variables.

When an python object is created by the runtime the instance dict is actually empty, no object actually has any instance attributes (unless the class defines `__slots__` which will in fact allocate named fields), until the `__init__` method is called. In the init method we are basically monkey patching in our instance attributes. This sets the key corresponding to the name of the attribute in the instance dict.

```python
#! /usr/bin/env python3

class TestClass:

    foo = 0

    def __init__(self):

        print(dir(self))
        # =>> ['__class__', '__delattr__', '__dict__', '__dir__', '__doc__',
        # '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__',
        # '__hash__', '__init__', '__le__', '__lt__', '__module__', '__ne__',
        # '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__',
        # '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'foo',
        # 'method']
        # only shows us the names of methods or attributed we defined on the class

        # we can refer to the instance dict directly using __dict__
        print(self.__dict__)
        # =>> {}

        # this is an alternative way to get the instance dict
        print(vars(self))

        self.bar = 'hi there'

        print(dir(self))
        # =>> ['__class__', '__delattr__', '__dict__', '__dir__', '__doc__',
        # '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__',
        # '__hash__', '__init__', '__le__', '__lt__', '__module__', '__ne__',
        # '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__',
        # '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'bar',
        # 'foo', 'method']
        # now bar exists as well

        print(self.__dict__)
        # =>> {'bar': 'hi there'}

        print(self.__dict__['bar'])
        # =>> 'hi there'

    def method(self):
        pass


a = TestClass()

del a.__dict__['bar']
# we can delete keys directly in the dict

print(
    hasattr(a, 'bar')
)  # =>> False

print(
    'bar' in a.__dict__
)  # =>> False

a.bar
# =>> AttributeError: 'TestClass' object has no attribute 'bar'
```

## Patching classes

As you may have guessed already, if we're allowed to attach attributes to a function, we are also allowed to attach attributes to a class.

There are two ways for obtaining the class from an object.

```python
#! /usr/bin/env python3

class TestClass:
    pass


my_obj = TestClass()

print(
    type(my_obj)
)  # =>> <class '__main__.TestClass'> or <class 'get_class.TestClass'>

print(
    my_obj.__class__
)  # =>> <class '__main__.TestClass'> or <class 'get_class.TestClass'>

print(
    type(my_obj) is my_obj.__class__
)  # =>> True
```

I personally prefer directly referring to `__class__` if I'm about to tamper with it, but either one works fine.

Now we can add/remove our class attributes.

```python
#! /usr/bin/env python3

class TestClass:
    greeting = 'hello'


instance = TestClass()

print(
    TestClass.greeting
)  # =>> hello

print(
    TestClass.greeting is instance.greeting
)  # =>> True

# removing class attributes
del TestClass.greeting

print(
    hasattr(instance, 'greeting')
)  # =>> False

# and adding them
instance.__class__.greeting = 'hello again'
type(instance).greeting_2 = 'dear me'

print(
    TestClass.greeting
)  # =>> hello again

print(
    instance.greeting_2
)  # =>> dear me

print(
    'greeting_2' in TestClass.__dict__
)  # =>> True
```

### How it works

In python classes are just object. Instances of `type`. And like most objects their attributes can be freely modified, removed or added. They do have an instance dict `__dict__` as well, however in this case it is not a vanilla python `dict` but rather a `mappingproxy` object. This is the interface the python interpreter shows for the instance dicts of lots of builtin types and objects, and this particular dict-like structure can **not** be modified directly. `__setattr__` and `__delattr__` however work on (most) types.

This pretty much only applies to classes actually created using `class`, not to builtin types such as for example `object`, `function` and `type` itself.


## The fun stuff - advanced class patching

We've just learned that we can patch classes in python by modifying its instance dict, which contains the class attributes. You may be guessing it already, or you may have seen it, the instance dict of a class does not only contains the attributes but it also the methods that are defined on the class.

Furthermore if you print one such method the output says the type is `function`, not `method`.

In fact python does not have `methods` per se. Instead there are functions contained in a classes instance dict. When you have an instance of the class and you print the method referencing from the instance you'll notice that the type changes from `function` to `bound method`.

```python
#! /usr/bin/env python3

class MyClass:
    def a_method(self):
        return self


print(
    'a_method' in MyClass.__dict__
)  # =>> True

print(
    MyClass.a_method
)  # =>> <function MyClass.a_method at ...>

obj = MyClass()

print(
    obj.a_method
)  # =>> <bound method MyClass.a_method of <__main__.MyClass object at ...>>

print(
    obj.a_method()
)  # =>> <__main__.MyClass object at ...>

print(
    type(obj).a_method('hello')
)  # =>> hello
```

Bound methods are basically partially applied functions, where the first argument is the object the method has been called on.

As we can also see on line 25 a method can be called on the class directly which in which case you will have to provide the `self` argument yourself, what the type of that `self` argument is, is irrelevant, and not checked anywhere (by the language).

Since methods are just functions until called, we can make the assumption, that they are in fact class attributes that happen to be callable. And in fact if you look at Python classes that is exactly the case. As a practical result of methods being nothing but class attributes and class instance dict being modifiable we can begin to assume that perhaps methods can be modified in just the same way.

Let's see how it works:

```python
#! /usr/bin/env python3

class TestClass:

    def foo(self):

        print('foo is executing')
        print('self is {}'.format(self))


def bar(param1):
    print('bar is executing')
    print('self is {}'.format(param1))

a = TestClass()

TestClass.foo('of wrong type')  # <- notice we have to provide a 'self' parameter
# =>> foo is executing
# =>> self is of wrong type

bar('the first param')
# =>> bar is executing
# =>> self is the first param

a.foo()  # <- equivalent to TestClass.foo(a)
# =>> foo is executing
# =>> self is <__main__.TestClass object at ...>

# assigning new methods
TestClass.foo_2 = bar
# equivalent to type(a).foo_2 = bar

a.foo_2()
# =>> bar is executing
# =>> self is <__main__.TestClass object at ...>


# reassigning old ones
TestClass.foo = bar  # <- no errors

a.foo()
# =>> bar is executing
# =>> self is <__main__.TestClass object at ...>


# deleting methods
del TestClass.foo_2

a.foo_2()
# =>> AttributeError: 'TestClass' object has no attribute 'foo_2'
```


The added/reassigned/removed methods affect both new and old instances of the class (instantly).

*Do remember that you have to add methods __to the class__, not the instance/object.*

Now please note that this is highly unsafe practice. Technically you can remove pretty much any method from any object and it is very hard to find where and if that has been done.

There is some fun stuff you can do now, since the methods you declared yourself are not the only thing you can change. This is an example of how you can overwrite `__init__` to change the behavior of a class during object instantiation.

```python
#! /usr/bin/env python3

class BaseClass:
    def __init__(self):
        print(BaseClass.__init__, 'executing')


class SubClass(BaseClass):
    def __init__(self):
        print(SubClass.__init__, 'executing')
        super().__init__()

print('\ninstantiating', SubClass)
SubClass()
# =>> <function SubClass.__init__ at ...> executing
# =>> <function BaseClass.__init__ at ...> executing

print()

# removing it
del SubClass.__init__

print('\ninstantiating', SubClass, 'again')
SubClass()
# =>> <function BaseClass.__init__ at ...> executing

def new_init(self):
    print('I overwrote __init__')
    super(SubClass, self).__init__()

# and adding a new one
SubClass.__init__ = new_init

print('\ninstantiating', SubClass, 'one last time')
SubClass()
# =>> I overwrote __init__
# =>> <function BaseClass.__init__ at ...> executing
```

However you do not have to stop there.

Those that know how decorators work will be aware that they are just normal python functions and can be used as such.

```python
#! /usr/bin/env python3

def my_decorator(func):
    return func


# ergo

@my_decorator
def function1():
    pass


# is equivalent to

def function1():
    pass

function1 = my_decorator(function1)
```

We can use that fact to dynamically create classmethods and staticmethods.

```
#! /usr/bin/env python3

class TestClass:
    pass


def foo():
    print('foo is executing')

def bar(cls):
    print('bar is executing')
    print(cls)


TestClass.static_foo = staticmethod(foo)

TestClass.class_bar = classmethod(bar)


TestClass.static_foo()
# =>> foo is executing

TestClass.class_bar()
# =>> bar is executing
# =>> <class '__main__.TestClass'>
```

I can actually think of very few ways that this can be useful. You should of course not apply this to live objects, since the consequences are highly opaque.

One way of using this though is to take a bunch of classes and add common or dynamically constructed methods to them.

The following is an example of a decorator that can be applied to a class and if there are public class variable in the class, whose value is a type, it will remove them and dynamically construct an `__init__` method for the class which requires the names of those fields as keyword arguments, typechecks them and then adds them to the object.

We can easily construct this and then add this new `__init__` method to our class.

```python
#! /usr/bin/env python3


def auto_init(class_):

    def filter_func(fieldname):
        """
        Return True if the field is not private and its value is a type
        """
        if fieldname.startswith('_'):
            return False
        value = getattr(class_, fieldname)

        return isinstance(value, type)

    fields = filter(
        filter_func,
        class_.__dict__
    )

    fields_and_types = [(field, getattr(class_, field)) for field in fields]

    for field in fields:
        # delete the class attributed to prevent collision
        delattr(class_, field)

    # preserve the old init, this is a safety measure
    old_init = getattr(class_, '__init__')
    # if the class does not define this itself, this will be super.__init__
    # which is convenient  

    def new_init(self, **kwargs):
        # only accept kwargs, because otherwise there's no way of
        # matching the fields

        for field, type_ in fields_and_types:

            # check whether the field is present
            # for simplicity's sake I do not handle extra arguments
            if field not in kwargs:
                raise TypeError(
                    'Expected keyword Argument {}'.format(field)
                )
            value = kwargs[field]

            # typecheck the field
            if not isinstance(value, type_):
                raise TypeError(
                    'Expected instance of {} for field {}'.format(
                        type_, field
                    )
                )

            # essentially self.field = value
            setattr(self, field, value)

        old_init(self)  # for completeness sake

    class_.__init__ = new_init

    return class_


@auto_init
class TestClass:
    foo = int
    bar = int
    glob = str


a = TestClass(foo=0, bar=8, glob="globbi globbi globbi")
b = TestClass(foo=8, bar=8, glob="")

print(a.foo)
# =>> 0
print(b.foo)
# =>> 8

print(b.bar == a.bar)
# =>> True

print(b.glob != a.glob)
# =>> True

print(a.glob)
# =>> globbi globbi globbi


try:
    TestClass()
except Exception as e:
    print(e)
    # =>> Expected keyword Argument foo

try:
    TestClass(foo=object, bar=0, glob="eirjg")
except Exception as e:
    print(e)
    # =>> Expected instance of <class 'int'> for field foo
```

You could just as easily add more to this decorator. The fields it adds could be private by default and it could also add dynamic accessor methods. Instead of just writing types to the class attributes, you could provide further meta information and construct appropriate accessor methods or even not create fields at all and instead create field mimicking accessor methods using `@property`. This can be very useful if your object is tying to hide (or simplify) access to a database or external system by imitating a normal object but instead of accessing fields it may make a database or network connection or read from a file.   

All in all it is I think useful to know that these things are possible, and if used correctly certainly can be a powerful tool. I like the possibilities but I also have never really used it in practice.

Let me know if you'd be interested to see more 'useful' application of this concept and I might make another post about it.
