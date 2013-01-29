require 'json'
require 'timeout'
require 'sinatra'
require 'haml'
require './config/setup'

# open config
config = JSON.parse IO.read("./config/att-api.json")

# setup sinatra
configure do
  set :environment, :development
  set :logging, true
  set :dump_errors, true
  set :raise_errors, true
  set :port, config['port']
  set :public_folder, 'public'
  puts "Setup Sinatra Server at #{config['local_server']}:#{config['port']}"
end

# setup routes
get '/' do 
  send_file File.join(settings.public_folder, 'index.html')
end

get '/test_executions' do
  sleep 1
  result = TestExecution.all(:order => [:created_date.desc])
  
  content_type :json
  '{"success": true, "data":'+ result.to_json(:methods => [:results]) +'}'
end

get '/last_test_results' do
  sleep 1
  test_execution = TestExecution.last
  results = []
  
  test_execution.results.each do |result|
    results << result.attributes.merge({
      :test_execution_id =>           test_execution.id,
      :test_execution_created_date => test_execution.created_date,
      :test_execution_status =>       test_execution.status
    })
  end
  
  content_type :json
  results.to_json
end

get '/api_method_details' do
  test_results = TestResult.all(:method_id => params[:method_id])
  test_results.to_json
end