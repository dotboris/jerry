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

### Dealing with settings

Sometimes, you want to wire settings into your classes. This is stuff like URIs,
host names, port numbers, credentials and API keys. With jerry, you can just
wire those into the constructor like you would do with regular classes. Let's
look at an example.

For this example, we're trying to wire together an application that talks to a
database. The database has a URI that it connects to. Here's what it looks like.

```ruby
class Database
  def initialize(uri)
    @uri = uri
  end
end

class Application
  def initialize(db)
    @db = db
  end
end
```

We can write a simple configuration for these classes. Here's what it looks
like.

```ruby
class AppConfig < Jerry::Config
  def initialize(database_uri)
    @database_uri = database_uri
  end

  bind Database, [proc { @database_uri }]
  bind Application, [Database]
end

jerry = Jerry.new AppConfig.new('foo://localhost:1234')
jerry[Application]
#=> #<Application:0x0000000178c110
#       @db=#<Database:0x0000000178c138 @uri="foo://localhost:1234">>
```

There are two key things to notice here. First, `AppConfig` takes a single
constructor argument. It's the database's URI. It takes this argument and stores
it as an instance variable. Second, it passes a proc in the argument
specification of the `bind` call. This is how the database uri is passed to the
constructor. The proc is executed in the configuration's context. This means
that you can access all the private methods and instance variables of the
configuration.

### Wire one class in multiple ways

Sometimes, you want to wire a single class in more than one way. One example of
this would be an application that connects to two databases. Here's what the
classes would look like:

```ruby
class Database
  attr_reader :uri

  def initialize(uri)
    @uri = uri
  end
end

class Application
  attr_reader :foo_db, :bar_db

  def initialize(foo_db, bar_db)
    @foo_db = foo_db
    @bar_db = bar_db
  end
end
```

What we need here is two instances of the `Database` class. Each instance has
a different URI. This can be done by using `named_bind`. Here's what it looks
like:

```ruby
class MultiDbAppConfig < Jerry::Config
  def initialize(foo_uri, bar_uri)
    @foo_uri = foo_uri
    @bar_uri = bar_uri
  end

  named_bind :foo_db, Database, [proc { @foo_uri }]
  named_bind :bar_db, Database, [proc { @bar_uri }]
  bind Application, [:foo_db, :bar_db]
end

jerry = Jerry.new MultiDbAppConfig.new(
  'somedb://foo.db.net',
  'somedb://bar.db.net'
)

jerry[Application]
#=> #<Application:0x00000001b56340
#     @bar_db=#<Database:0x00000001b56430 @uri="somedb://bar.db.net">,
#     @foo_db=#<Database:0x00000001b565e8 @uri="somedb://foo.db.net">>
```

In the above example, we define a config that takes two arguments in its
constructor. These are the URIs for the two databases (here called `foo` and
`bar`).

In this config, we use `named_bind` to tell jerry how to wire an instance of
`Database` called `:foo_db` constructed by passing in `@foo_uri` as its first
constructor argument. We do the same thing to tell jerry how to wire another
instance of `Database` called `:bar_db` constructed by passing in `@bar_uri` as
its first constructor argument.

Finally, we use `bind` to tell jerry how to wire instances of `Application`.
When specifying the constructor arguments, we use their names (`:foo_db` and
`:bar_db`) to identify them.

### Multiples configurations

Jerry allows you to define and use multiple configurations. This way you can
separate the dependency configurations for different parts of your application.

Let's look at an example. In this example, we have a simple on-line store. It
has users, products and shopping carts. We can create separate configurations
for user, product, and shopping cart related classed. Users, products and
shopping carts each have a service that talks to the database and other services
and a controller that talks to the service. Here's what it might look like:

```ruby
class DatabaseConfig < Jerry::Config
  # database connector thingy
  bind Database
end

class UserConfig < Jerry::Config
  bind UserService, [Database]
  bind UserController, [UserService]
end

class ProductConfig < Jerry::Config
  bind ProductService, [Database]
  bind ProductController, [ProductService]
end

class ShoppingCartConfig < Jerry::Config
  bind ShoppingCartService, [Database, ProductService, UserService]
  bind ShoppingCartController, [ShoppingCartService]
end

class AppConfig < Jerry::Config
  bind Application, [UserController, ProductController, ShoppingCartController]
end

jerry = Jerry.new(
  DatabaseConfig.new,
  AppConfig.new,
  UserConfig.new,
  ProductConfig.new,
  ShoppingCartConfig.new
)

app = jerry[Application]
```

Note that in the example above, some the configurations reference classes that
are configured in other configurations. This is perfectly fine. When
instantiating a class, jerry will look at all the configurations.
