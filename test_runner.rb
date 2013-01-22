require 'json'
require './config/setup'
require './att_api_reporter'

# open config
$config = JSON.parse IO.read("conf/att-api.json")

# execute tests
begin
  while true
    puts "\n== Starting Test Execution ==\n"
    
    # setup reporter
    $reporter = AttApiReporter.new(
      baseURL:      $config['apiHost'].to_s,
      clientID:     $config['apiKey'].to_s,
      clientSecret: $config['secretKey'].to_s,
      shortCode:    $config['shortCode'].to_s,
      oauth_token:  $config['oauth_token'],
      userID:       $config['userID'].to_s,
      password:     $config['password'].to_s,
      tel:          $config['tel'].to_s,
      localServer:  $config['localServer'].to_s + ':' + $config['port'].to_s
    )

    # save test execution
    test_execution = TestExecution.create(
      created_at: Time.now,
      status: TestExecution::RUNNING
    )
    test_execution.save

    # run
    $reporter.run

    # update test
    test_execution.update({
      status: TestExecution::COMPLETED,
      finished_at: Time.now
    })
    
    puts "\nFinishing Test Execution with Success"
    puts "Next test will run in 1 hour..."
    
    #wait 1 hour
    sleep 3600 
  end
rescue => e
  puts "\nLogging Error"
  puts e.inspect
  puts e.backtrace
  
  puts "\nFinishing Test Execution with Error"
  test_execution.update({
    status: TestExecution::ERROR,
    finished_at: Time.now
  })
end