require 'json'
require 'timeout'
require 'sinatra'
require 'haml'
require './config/setup'

# open config
$config = JSON.parse IO.read("conf/att-api.json")

# setup sinatra
configure do
  set :environment, :development
  set :logging, true
  set :dump_errors, true
  set :raise_errors, true
  set :port, $config['port']
end

# setup helpers
helpers do
  def cls(text)
    return 'grn' if text == 'YES'
    return 'red' if text == 'NO'
    return 'gry' if text == 'N/A'
    return ''
  end

  def timing(text)
    val = text.to_i
    return 'grnb' if val < 5
    return 'redb' if text.to_i > 8
    return 'yelb'
  end
end

# setup routes

get '/status_summary' do
  content_type :json
  {
    :success => true,
    :data => {
      :testsStartTime =>  $testsStartTime,
      :testsStartTimeEpoch => $testsStartTime.to_i,
      :testsAreRunning => $testsAreRunning,
      :baseURL => $reporter.base_url,
      :testUser => $reporter.user_id,
      :testPassword => $reporter.password,
      :clientID => $reporter.client_id,
      :clientSecret => $reporter.client_secret,
      :tel => $reporter.tel,
      :shortCode => $reporter.short_code,
      :localServer => $reporter.local_server
    }
  }.to_json
end


get '/status_data' do
  content_type :json
  tests =  $reporter.tests
  result = []
  
  tests.each do |test|
    last_row = nil
    file_path = "results/#{test['id']}.csv"
    
    if File.exist?(file_path)
      CSV.foreach(file_path) do |row|
        last_row = row
      end
    end
    
    if last_row
      result << {
        id: test['id'],
        name: test['name'],
        api_name: test['api_name'],
        start_time: last_row[0].to_i,
        duration: last_row[1].to_f,
        result: last_row[2].to_i
      }
    end
  end
  
  JSON.unparse({
    tests: result
  })
end


get '/history/:test' do
  testName = params[:test]

  file = File.new("results/#{testName}.csv", 'r')
  results = []
   file.each_line("\n") do |row|
     columns = row.split(",")
     columns.push(Time.at(Integer(columns[0])).strftime("%R"))
     columns.push(Time.at(Integer(columns[0])).strftime("%m/%d/%Y %R:%S"))
     results << columns
   end

  #haml :history, :locals => {  :baseURL => $reporter.base_url,:testUser => $reporter.user_id, :testName => testName, :resultsChron  => results[0,48], :results  => results.reverse}
  haml :history, :locals => {  :baseURL => $reporter.base_url,:testUser => $reporter.user_id, :testName => testName, :resultsChron  => results, :results  => results.reverse}
end


get '/history_data' do
  content_type :json
  testName = params['testName']

  file = File.new("results/#{testName}.csv", 'r')
  results = []
   file.each_line("\n") do |row|
     columns = row.split(",")
     results << [columns[0].to_i, columns[1].to_f, columns[2].chomp]
   end

   '{ data : ' + results.to_json + '}'
end

get '/history_data_paged' do
  content_type :json
  testName = params['testName']
  start = params['start'] || 0
  limit = params['limit'] || 20

  tmpRows = IO.readlines("results/#{testName}.csv")
  total = tmpRows.length
  rows = tmpRows[start.to_i, limit.to_i]
  results = []
  rows.each do |row|
    columns = row.split(",")
    results << [columns[0].to_i, columns[1].to_f, columns[2].chomp]
  end

   '{ total : ' + total.to_s + ', data : ' + results.to_json + '}'
end

get '/history_data_csv' do
  content_type :text
  testName = params['testName']

  send_file "results/#{testName}.csv", :filename=>"#{testName}.csv", :type=>"text/csv"

end


get '/history_oauth_data' do
  content_type :json

  tests = ['oauth_fetch_login','oauth_login','oauth_authorize', 'oauth_gettoken']
  testDataCombined = []

  tests.each do |testName|
    testData = {}
    file = File.new("results/#{testName}.csv", 'r')
    file.each_line("\n") do |row|
       columns = row.split(",")
       # column 0 is the start_date (the key for our hash)
       # column 1 is the duration in seconds
       # column 2 is the msg (OK, FAILED, SKIPPED)

       # add to our hash the array
       testData[columns[0]] = [columns[1], columns[2]]
    end
    testDataCombined.push(testData)
  end

  results = []
  oauthFetch = testDataCombined[0]
  oauthLogin = testDataCombined[1]
  oauthAuthorize = testDataCombined[2]
  oauthGetToken = testDataCombined[3]

  oauthFetch.each do |start_time,dataArray|
    if (oauthLogin[start_time].nil?)
      oauthLogin[start_time] = [0, 'SKIPPED']
    end
    if (oauthAuthorize[start_time].nil?)
      oauthAuthorize[start_time] = [0, 'SKIPPED']
    end
    if (oauthGetToken[start_time].nil?)
      oauthGetToken[start_time] = [0, 'SKIPPED']
    end

    results << [start_time.to_f, oauthFetch[start_time][0].to_f, oauthFetch[start_time][1].chomp, oauthLogin[start_time][0].to_f, oauthLogin[start_time][1].chomp, oauthAuthorize[start_time][0].to_f, oauthAuthorize[start_time][1].chomp, oauthGetToken[start_time][0].to_f, oauthGetToken[start_time][1].chomp]
  end

  results = results.sort_by{|data| data[0]}
  '{ data : ' + results.to_json + '}'
end

get '/history_oauth_data_paged' do
  content_type :json
  start = params['start'] || 0
  limit = params['limit'] || 20
  total = 0

  tests = ['oauth_fetch_login','oauth_login','oauth_authorize', 'oauth_gettoken']
  testDataCombined = []

  tests.each do |testName|
    testData = {}
    rows = IO.readlines("results/#{testName}.csv")
    rows.each do |row|
      columns = row.split(",")
      # column 0 is the start_date (the key for our hash)
      # column 1 is the duration in seconds
      # column 2 is the msg (OK, FAILED, SKIPPED)

      # add to our hash the array
      testData[columns[0]] = [columns[1], columns[2]]
    end
    testDataCombined.push(testData)
  end

  results = []
  oauthFetch = testDataCombined[0]
  oauthLogin = testDataCombined[1]
  oauthAuthorize = testDataCombined[2]
  oauthGetToken = testDataCombined[3]

  oauthFetch.each do |start_time,dataArray|
    if (oauthLogin[start_time].nil?)
      oauthLogin[start_time] = [0, 'SKIPPED']
    end
    if (oauthAuthorize[start_time].nil?)
      oauthAuthorize[start_time] = [0, 'SKIPPED']
    end
    if (oauthGetToken[start_time].nil?)
      oauthGetToken[start_time] = [0, 'SKIPPED']
    end

    results << [start_time.to_f, oauthFetch[start_time][0].to_f, oauthFetch[start_time][1].chomp, oauthLogin[start_time][0].to_f, oauthLogin[start_time][1].chomp, oauthAuthorize[start_time][0].to_f, oauthAuthorize[start_time][1].chomp, oauthGetToken[start_time][0].to_f, oauthGetToken[start_time][1].chomp]
  end

  results = results.sort_by{|data| data[0]}
  total = results.length
  results = results[start.to_i, limit.to_i]
  '{ total : ' + total.to_s + ', data : ' + results.to_json + '}'
end

get '/log/:ts' do
  timestamp = params[:ts]
  testNames =  $reporter.test_names()

  testTime= Time.at(Integer(timestamp)).strftime("%m/%d/%Y %R:%S")

  begin
    log = YAML::load( File.open( "logs/#{timestamp}.yml" ) )
    haml :log, :locals => { :testTime => testTime, :testResults => log, :testNames => testNames, :baseURL => $reporter.base_url}
  rescue Exception => e
    haml :log_error, :locals => { :testTime => testTime}
  end
end

get '/log_data' do
  content_type :json

  timestamp = params['ts']
  testTime= Time.at(Integer(timestamp)).strftime("%m/%d/%Y %R:%S")

  testNames =  $reporter.test_names()
  testResults = []
  results = []

  begin
    testResults = YAML::load( File.open( "logs/#{timestamp}.yml" ) )
    testNames.each do |testName|
      results << {'test'=>testName, 'errors'=>testResults[testName]['errors']}
    end
  rescue Exception => e
    testResults = []
    results << {'test'=>'exception', 'errors'=>'exception'}
  end


  '{data : ' + results.to_json + '}'

end


get '/stylesheet.css' do
  scss :stylesheet
end


get '/oauth_chart' do
  haml :oauth
end
