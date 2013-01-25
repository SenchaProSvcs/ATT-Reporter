class TestResult
  include DataMapper::Resource

  PASSED = 1
  WARNING = 2
  ERROR = 3
  
  belongs_to :test_execution
  
  property :id,           Serial
  property :method_id,    String
  property :name,         String
  property :api_name,     String
  property :created_date, String
  property :finished_date,String
  property :duration,     Float
  property :result,       Integer
  
  attr_accessor :api_id
  attr_accessor :url
  attr_accessor :verb
  attr_accessor :headers
  attr_accessor :data
  
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