Jerry
=====

[![Build Status](https://travis-ci.org/beraboris/jerry.svg?branch=master)](https://travis-ci.org/beraboris/jerry)
[![Coverage Status](https://coveralls.io/repos/beraboris/jerry/badge.png)](https://coveralls.io/r/beraboris/jerry)


Jerry is a Ruby
[Inversion of Control](https://en.wikipedia.org/wiki/Inversion_of_control)
container. You tell it how your classes depend on one another and it will create
your application and wire all the dependencies correctly.

Installation
------------

Add it to your `Gemfile`

```ruby
gem 'jerry', '~> 2.0'
```

then run

    $ bundle install

Usage
-----

Jerry expect your classes to take their dependencies in their constructors. If
you're not familiar with this pattern, it's called
[Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection).
It helps you decouple your code and allows you to build reusable components.

Let's say you have the following class structure:

```ruby
class Door; end
class Window; end

class House
  def initialize(door, window)
    # ...
  end
end
```

To create an instance of `House`, you need to call `new` passing an both an
instance of `Door` and an instance of `Window`. Jerry can do this for you. All
you have to do is create a configuration and tell jerry to use it.

```ruby
require 'jerry'

class HouseConfig < Jerry::Config
  bind Door
  bind Window
  bind House, [Door, Window]
end

jerry = Jerry.new HouseConfig.new
jerry[House]
# => #<House:0x00000002a54978
#        @door=#<Door:0x00000002a54b08>,
#        @window=#<Window:0x00000002a549a0>>
```

Let's break the above example down a little bit.

First, we create the `HouseConfig` class.

`HouseConfig` is used to tell jerry how to build your classes. This is a
class you have to create. It has to inherit from `Jerry::Config`. Within this
class you can use `bind` to tell jerry how to instantiate your classes.

`bind` takes two arguments. The first is the class you're telling jerry about.
The second is a specification for the constructor arguments. If the second
argument is missing, no arguments will be passed to the constructor.

When we're calling `bind Door`, we're telling jerry that the `Door` class should
be instantiated by calling the constructor with no arguments. We're doing the
same thing for `Window` class.

When we're calling `bind House, [Door, Window]`, we're telling jerry that the
`House` class should be instantiated calling the constructor and passing an
instance of `Door` as the first argument and an instance of `Window` as the
second argument. Since we've told jerry about the `Door` and `Window` classes,
it'll figure out how to instantiate those all by itself.

Second, we create an instance of the `Jerry` class passing in an instance of our
configuration class. What's cool is that you can have multiple configurations.
We'll look into this later on.

Finally, we ask jerry to create an instance of the `House` class by using the
`[]` operator. As you can see from the output, jerry passed in an instance of
`Door` and `Window`.
