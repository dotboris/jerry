require 'jerry'

module ShoppingCart
  class DatabaseConfig < Jerry::Config
    bind Database, [proc { 'foo://localhost:9001' }]
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

  class ApplicationConfig < Jerry::Config
    bind Application,
         [UserController, ProductController, ShoppingCartController]
  end
end
