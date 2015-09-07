require 'jerry'
require 'fixtures/house'
require 'fixtures/db_app'
require 'fixtures/shopping_cart'
require 'fixtures/shopping_cart_config'
require 'fixtures/multi_db_app'

describe Jerry do
  def double_config(name, fields = {})
    config = double name, fields
    allow(config).to receive(:jerry=)
    config
  end

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

  it 'should set the jerry attribute on the configs' do
    alfa = spy 'alfa config'
    bravo = spy 'bravo config'
    charlie = spy 'charlie config'

    jerry = Jerry.new alfa, bravo, charlie

    expect(alfa).to have_received(:jerry=).with(jerry)
    expect(bravo).to have_received(:jerry=).with(jerry)
    expect(charlie).to have_received(:jerry=).with(jerry)
  end

  describe '#[]' do
    it 'should delegate to configs' do
      config = double_config 'config'
      allow(config).to receive(:knows?).and_return(true)
      jerry = Jerry.new config

      expect(config).to receive(:[]).with(House)

      jerry[House]
    end

    it 'should return the provided value from the config' do
      instance = double 'some value'
      config = double_config 'config'
      allow(config).to receive(:knows?).and_return(true)
      allow(config).to receive(:[]).and_return(instance)
      jerry = Jerry.new config

      expect(jerry[House]).to eq instance
    end

    it 'should prioritize configs by their order in the constructor' do
      alfa = double_config 'alfa config'
      allow(alfa).to receive(:knows?).and_return(false)
      bravo = double_config 'bravo config'
      allow(bravo).to receive(:knows?).and_return(true)
      bravo_instance = double 'instance from bravo'
      allow(bravo).to receive(:[]).and_return(bravo_instance)
      charlie = double_config 'charlie config'
      allow(charlie).to receive(:knows?).and_return(true)
      charlie_instance = double 'instance from charlie'
      allow(charlie).to receive(:[]).and_return(charlie_instance)

      jerry = Jerry.new alfa, bravo, charlie

      expect(jerry[:something]).to eq bravo_instance
    end

    it 'should fail if no config know the key' do
      configs = 3.times.map { double_config 'some config', knows?: false }
      jerry = Jerry.new(*configs)

      expect { jerry[:not_there] }.to raise_error(Jerry::InstantiationError)
    end
  end
end
