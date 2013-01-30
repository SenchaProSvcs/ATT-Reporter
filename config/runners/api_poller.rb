require 'json'
require './config/setup'

# open config
config = JSON.parse IO.read("./config/att-api.json")

# execute tests
begin
  while true
    puts "\n== Starting Test Execution ==\n"
    
    # save test execution
    test_execution = TestExecution.create(
      :created_at => Time.now,
      :status => TestExecution::RUNNING
    )

    # init reporter
    reporter = AttApiReporter.new(config, test_execution)

    # update test
    test_execution.update({
      :status => TestExecution::COMPLETED,
      :finished_at => Time.now
    })
    test_execution = nil
    
    puts "\nFinishing Test Execution with Success"
    puts "Next test will run in 1 hour..."
    
    #wait 1 hour
    sleep 3600 
  end
    
rescue SystemExit, Interrupt
  puts "Testing interrupted. Clearing up tests. INTERRUPTING THIS PROCESS MAY CORRUPT DATABASE DATA"

  if test_execution
    test_execution.results.destroy
    test_execution.destroy  
  end
  
rescue => e
  puts "\nLogging Error"
  puts e.inspect
  puts e.backtrace
  
  unless test_execution.nil?
    puts "\nFinishing Test Execution with Error"
    test_execution.update({
      :status => TestExecution::ERROR,
      :finished_at => Time.now
    }) 
  end
end