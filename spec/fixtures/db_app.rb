# A database connector that connects to a given uri
class Database
  attr_reader :uri

  def initialize(uri)
    @uri = uri
  end
end

# An application that uses a database
class DbApplication
  attr_reader :db

  def initialize(db)
    @db = db
  end
end
