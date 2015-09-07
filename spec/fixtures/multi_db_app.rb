require 'jerry'

module MultiDbApp
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

  class Config < Jerry::Config
    def initialize(foo_uri, bar_uri)
      @foo_uri = foo_uri
      @bar_uri = bar_uri
    end

    named_bind :foo_db, Database, [proc { @foo_uri }]
    named_bind :bar_db, Database, [proc { @bar_uri }]
    bind Application, [:foo_db, :bar_db]
  end
end
