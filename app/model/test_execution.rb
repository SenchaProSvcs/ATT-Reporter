class TestExecution
  include DataMapper::Resource

  RUNNING = 1
  COMPLETED = 2
  ERROR = 3

  property :id,         Serial
  property :created_at, DateTime
  property :finished_at,DateTime
  property :status,     Integer
end