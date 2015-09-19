Jerry
=====

[![Build Status](https://travis-ci.org/beraboris/jerry.svg?branch=master)](https://travis-ci.org/beraboris/jerry)
[![Coverage Status](https://coveralls.io/repos/beraboris/jerry/badge.png)](https://coveralls.io/r/beraboris/jerry)

Jerry is a Ruby
[Inversion of Control](https://en.wikipedia.org/wiki/Inversion_of_control)
container. You tell it how your classes depend on one another and it will create
your application and wire all the dependencies correctly.

Jerry aims to be simple and straight forward. It also aims to be out of your
way. Your classes don't need to know anything about jerry.

Why?
----

[Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) is a
great pattern for building loosely coupled applications. It allows you to build
isolated components that can be swapped around.

The problem with this pattern is that it leaves you with a bunch of classes that
you have to build and wire together yourself. Jerry does that for you.

Getting started
---------------

### Important note

Currently jerry only supports constructor injection. If you're hoping to use
setter injection, you're out of luck. You're going to need to switch to
constructor injection.

### Install it

You have 3 options:

Options 1: Add jerry to your `Gemfile`

```ruby
gem 'jerry', '~> 2.0'
```

Option 2: Add jerry to your `*.gemspec`

```ruby
Gem::Specification.new do |spec|
  # ...
  spec.add_dependency 'jerry', '~> 2.0'
end
```

Option 3: Just install it

    $ gem install jerry

### Create a configuration class

```ruby
require 'jerry'

class MyConfig < Jerry::Config
  def initialize(foo_db_url, bar_db_url)
    @foo_db_url = foo_db_url
    @bar_db_url = bar_db_url
  end

  bind Application, [FooService, BarService]

  singleton bind FooService, [BarService, :foo_db]
  singleton bind BarService, [:bar_db]

  named_bind :foo_db Database [proc { @foo_db_url }]
  named_bind :bar_db Database [proc { @bar_db_url }]
end
```

Let's go over what's going on in this configuration class.

First, we define a constructor. It takes two database urls and stores them as
instance variables. We'll go over what these urls are used for later. You should
note that this constructor has no special meaning to jerry. It's entirely
specific to this configuration class.

Second, we use `bind` to tell jerry how to wire the `Application` class. `bind`
takes two arguments. The first is the class we're telling jerry about and the
second is an array that tells jerry what constructor arguments to pass to the
class. Here you can notice that `Application` takes an instance of `FooService`
and an instance of `BarService` in its constructor.

Third, we tell jerry how to build `FooService` and `BarService`. Note that we're
calling `singleton bind` instead of `bind` here. `singleton` is used to tell
jerry that we want it to only instantiate the class we just described only once.
When we use `singleton` jerry will always pass the same instance of the given
class as a constructor argument. This is useful when some of your classes have
a persistent state. In this case, the `BarService` instance passed to both
`Application` and `FooService` will be the exact same instance.

Finally, we tell jerry how to build two instances of the `Database` class. The
first instance is named `:foo_db` and the second is named `:bar_db`. We
reference these instances when telling jerry about `FooService` and
`BarService`. This is what `named_bind` is for. We should also note that the
last arguments of the `named_bind` calls each contain a proc. In this case, the
procs are used to inject the database urls for each database. In a more general
sense, the procs are used to pass settings to various classes.

### Create your application

```ruby
require 'jerry'

jerry = Jerry.new MyConfig.new('db://localhost/foo', 'db://localhost/bar')
app = jerry[Application]
```

Let's look at what's going on here.

First, we create an instance of our configuration class. We pass the urls for
our two databases to the constructor.

Second, we create an instance of `Jerry` passing in the instance of our
configuration class.

Finally, we use the square bracket operator (`[]`) to create an instance of our
application. Of course our application is wired properly.

Learn more
----------

If you'd like to learn more, here's some more documentation:

- [Multiple configurations](doc/multiple-configurations)
