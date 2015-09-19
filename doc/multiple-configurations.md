Multiple configurations
-----------------------

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
