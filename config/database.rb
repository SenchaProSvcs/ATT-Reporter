require  'data_mapper'
require  'dm-migrations'

# Setup DataMapper (http://datamapper.org/getting-started.html)
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/data/database.db")
DataMapper::Model.raise_on_save_failure = true

# Setup Models
require './app/model/test_execution'

DataMapper.finalize
DataMapper.auto_upgrade!