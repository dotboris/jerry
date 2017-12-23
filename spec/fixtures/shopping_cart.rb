module ShoppingCart
  class Database
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end
  end

  class UserService
    attr_reader :db

    def initialize(db)
      @db = db
    end
  end

  class ProductService
    attr_reader :db

    def initialize(db)
      @db = db
    end
  end

  class ShoppingCartService
    attr_reader :db, :product_service, :user_service

    def initialize(db, product_service, user_service)
      @db = db
      @product_service = product_service
      @user_service = user_service
    end
  end

  class UserController
    attr_reader :user_service

    def initialize(user_service)
      @user_service = user_service
    end
  end

  class ProductController
    attr_reader :product_service

    def initialize(product_service)
      @product_service = product_service
    end
  end

  class ShoppingCartController
    attr_reader :shopping_cart_service

    def initialize(shopping_cart_service)
      @shopping_cart_service = shopping_cart_service
    end
  end

  class Application
    attr_reader :user_controller, :product_controller, :shopping_cart_controller

    def initialize(user_controller, product_controller,
                   shopping_cart_controller)
      @user_controller = user_controller
      @product_controller = product_controller
      @shopping_cart_controller = shopping_cart_controller
    end
  end
end
