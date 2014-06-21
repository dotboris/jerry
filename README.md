Jerry
=====

[![Build Status](https://travis-ci.org/beraboris/jerry.svg?branch=master)](https://travis-ci.org/beraboris/jerry)
[![Coverage Status](https://coveralls.io/repos/beraboris/jerry/badge.png)](https://coveralls.io/r/beraboris/jerry)

Jerry rigs your application together. It's an [Inversion of Control](https://en.wikipedia.org/wiki/Inversion_of_control)
container for ruby. Just tell Jerry how to build your application and it will set it all up for you.

Installation
============

The usual stuff. Either

    gem 'jerry'

then

    $ bundle install

or

    $ gem install jerry

Usage
=====

Let's say you have the following code:

    class Window; end
    class Door; end
    
    class House
      attr_reader :window, :door
      
      def initialize(window, door)
        @window = window
        @door = door
      end
    end

First, require jerry:

    require 'jerry'
    
Then, define a config class. This class tells jerry how to construct your application.

    class MyConfig < Jerry::Config
      component(:window) { Window.new }
      component(:door) { Door.new }
      component(:house) { House.new rig(:window), rig(:door) }
    end

The `component` method defines a component. Usually you'll want a component per class. The `rig` method tells jerry to
build a component.

Finally, when you want to build your application, ask jerry to do it for you.

    jerry = Jerry.new MyConfig.new
    house = jerry.rig :house

Scopes
------

The `component` method let's you specify a scope. The scope can either be `:single` or `:instance` and the default is
`:single`. If you set the scope to `:single` only one instance of the component will be created. If you set it to
`:instance`, a new instance of the component will be created each time you call `rig`.

    class MyConfig < Jerry::Config
      component(:window, scope: :instance) { Window.new }
      component(:door, scope: :single) { Door.new }
    end
    jerry = Jerry.new MyConfig.new
    
    window_a = jerry.rig :window
    window_b = jerry.rig :window
    window_a.object_id == window_b.object_id
    #=> false
    
    door_a = jerry.rig :door
    door_b = jerry.rig :door
    door_a.object_id == door_b.object_id
    #=> true

Multiple configs
----------------

Jerry let's you use multiple configs. This way you can organize your configs however you want. You can pass multiple
configs to `Jerry.new` or you can use `jerry << SomeConfig.new` to add configs to jerry.

If two configs define the same component, the config that was inserted last will have priority. With `Jerry.new`, the
later arguments have priority.

    class ConfA < Jerry::Config
      component(:thing) { "from a" }
    end
    class ConfB < Jerry::Config
      component(:thing) { "from b" }
    end
    jerry = Jerry.new ConfA.new, ConfB.new
    
    jerry.rig :thing
    #=> "from b"
