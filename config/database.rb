require  'data_mapper'
require  'dm-migrations'
require  'dm-serializer'
require  'dm-pager'

# Setup DataMapper (http://datamapper.org/getting-started.html)
DataMapper::Logger.new($stdout, :error)
DataMapper.setup(:default, 'sqlite://' + File.join(File.dirname(__FILE__), '..', 'data', 'database.db'))
DataMapper::Model.raise_on_save_failure = true

# Setup Models
require './app/model/test_execution'
require './app/model/test_result'

DataMapper.finalize
DataMapper.auto_upgrade!