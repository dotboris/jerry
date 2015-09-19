require 'jerry'
require 'fixtures/house'
require 'fixtures/db_app'
require 'fixtures/shopping_cart'
require 'fixtures/shopping_cart_config'
require 'fixtures/multi_db_app'

describe Jerry do
  it 'should wire dependencies' do
    HousingModule = Class.new(Jerry::Config) do
      bind House, [Door, Window]
      bind Window, []
      bind Door, []
    end

    jerry = Jerry.new HousingModule.new

    house = jerry[House]

    expect(house).to be_a House
    expect(house.window).to be_a Window
    expect(house.door).to be_a Door
  end

  it 'should allow the use of procs to wire settings' do
    AppConfig = Class.new Jerry::Config do
      def initialize(database_uri)
        @database_uri = database_uri
      end

      bind DbApplication, [Database]
      bind Database, [proc { @database_uri }]
    end

    jerry = Jerry.new AppConfig.new('mongodb://localhost:27017')
    app = jerry[DbApplication]

    expect(app).to be_a DbApplication
    expect(app.db).to be_a Database
    expect(app.db.uri).to eq 'mongodb://localhost:27017'
  end

  it 'should support multiple configs' do
    jerry = Jerry.new(
      ShoppingCart::DatabaseConfig.new,
      ShoppingCart::ApplicationConfig.new,
      ShoppingCart::UserConfig.new,
      ShoppingCart::ProductConfig.new,
      ShoppingCart::ShoppingCartConfig.new
    )

    app = jerry[ShoppingCart::Application]

    expect(app).to be_a ShoppingCart::Application

    expect(app.user_controller).to be_a ShoppingCart::UserController
    expect(app.product_controller).to be_a ShoppingCart::ProductController
    expect(app.shopping_cart_controller).to \
      be_a ShoppingCart::ShoppingCartController

    expect(app.user_controller.user_service).to be_a ShoppingCart::UserService
    expect(app.product_controller.product_service).to \
      be_a ShoppingCart::ProductService
    expect(app.shopping_cart_controller.shopping_cart_service).to \
      be_a ShoppingCart::ShoppingCartService

    expect(app.user_controller.user_service.db).to be_a ShoppingCart::Database
    expect(app.product_controller.product_service.db).to \
      be_a ShoppingCart::Database
    expect(app.shopping_cart_controller.shopping_cart_service.db).to \
      be_a ShoppingCart::Database

    shopping_cart_service = app.shopping_cart_controller.shopping_cart_service
    expect(shopping_cart_service.user_service).to be_a ShoppingCart::UserService
    expect(shopping_cart_service.product_service).to \
      be_a ShoppingCart::ProductService
  end

  it 'should support wiring one class in multiple ways through naming' do
    jerry = Jerry.new MultiDbApp::Config.new('db://foo', 'db://bar')

    app = jerry[MultiDbApp::Application]

    expect(app.foo_db.uri).to eq 'db://foo'
    expect(app.bar_db.uri).to eq 'db://bar'
  end

  it 'should wire the same class multiple times with multiple names' do
    klass = Class.new do
      attr_reader :str
      define_method(:initialize) { |str| @str = str }
    end
    config = Class.new Jerry::Config do
      named_bind :foo, klass, [proc { 'foo' }]
      named_bind :bar, klass, [proc { 'bar' }]
    end
    jerry = Jerry.new config.new

    foo = jerry[:foo]
    bar = jerry[:bar]

    expect(foo).to be_a klass
    expect(foo.str).to eq 'foo'
    expect(bar).to be_a klass
    expect(bar.str).to eq 'bar'
  end

  it 'should always wire the same instance when using singleton' do
    klass = Class.new
    config = Class.new Jerry::Config do
      singleton bind klass
    end
    jerry = Jerry.new config.new

    alfa = jerry[klass]
    bravo = jerry[klass]

    expect(alfa).to equal bravo
  end
end
