class TestExecution
  include DataMapper::Resource
  
  RUNNING = 1
  COMPLETED = 2
  ERROR = 3
  
  has n, :results, 'TestResult',:parent_key => [:id], :child_key => [:test_execution_id]

  property :id,           Serial
  property :created_date, String
  property :finished_date,String
  property :status,       Integer
  
  def created_at=(value)
    self.created_date = value.strftime('%Y-%m-%d %H:%M:%S.%3N')
  end
  
  def created_at
    return @created_date ? Time.parse(@created_date) : nil
  end
  
  def finished_at=(value)
    self.finished_date = value.strftime('%Y-%m-%d %H:%M:%S.%3N')
  end
  
  def finished_at_time
    return @finished_date ? Time.parse(@finished_date) : nil
  end
end