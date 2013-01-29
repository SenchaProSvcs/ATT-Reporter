require 'curb'
require 'mechanize'
require 'logger'
require 'pp'
require 'active_support/core_ext'
require 'base64'
require 'yaml'

require 'timeout'
require 'rubygems'
require 'sinatra'
require 'haml'

require './config/setup'
require './lib/reporter/apis/att'
require './lib/reporter/apis/oauth'
require './lib/reporter/apis/device_location'
require './lib/reporter/apis/payments'
require './lib/reporter/apis/sms'
require './lib/reporter/apis/mms'
require './lib/reporter/apis/mmsv2'
require './lib/reporter/apis/notary'
require './lib/reporter/apis/wap'
require './lib/reporter/apis/speech'

class AttApiReporter
  include AttApi::Oauth
  include AttApi::DeviceLocation
  include AttApi::Notary
  include AttApi::Payments
  include AttApi::SMS
  include AttApi::MMS
  include AttApi::MMSv2
  include AttApi::Wap
  include AttApi::Speech

  attr_reader :tests
  attr_reader :config
  attr_reader :current_test
  attr_reader :oauth_token
  
  def initialize(config, test_execution)
    @config = config
    @oauth_token = config['oauth_token']
    # 
    # 
    # 
    # 
    #   baseURL:      $config['api_host'].to_s,
    #   clientID:     $config['api_key'].to_s,
    #   clientSecret: $config['secret_key'].to_s,
    #   short_code:    $config['short_code'].to_s,
    #   oauth_token:  $config['oauth_token'],
    #   user_id:       $config['user_id'].to_s,
    #   password:     $config['password'].to_s,
    #   tel:          $config['tel'].to_s,
    #   local_server:  $config['local_server'].to_s + ':' + $config['port'].to_s
    # )
    # 
    # 
    # @config['tel'] = conf[:tel]
    # 
    # @testNames = ['oauth_login', 'oauth_gettoken']
    # @testResults = {}
    # @authorize_failed = false
    # 
    # @testName = "*****"
    # 
    # raise "No baseURL specified" unless @config['api_host'] = conf[:baseURL]
    # raise "No clientID specified" unless @config['api_key'] = conf[:clientID]
    # raise "No clientSecret specified" unless @config['secret_key'] = conf[:clientSecret]
    #
    # create agent
    @agent = Mechanize.new
    @agent.read_timeout = 300
    @agent.open_timeout = 300
    # @agent.log = Logger.new(STDOUT)
    # 
    # parse API definition
    
    # Execute tests for each API method
    config['apis'].each do |api|
      api['methods'].each do |method|
        
        test_result = TestResult.new(
          :test_execution =>test_execution,
          :method_id =>     "#{api['id']}_#{method['id']}",
          :api_id =>        api['id'],
          :api_name =>      api['name'],
          :name =>          method['name'],
          :url =>           method['url'],
          :verb =>          method['verb'],
          :headers =>       method['headers'],
          :data =>          method['data'],
          :created_at =>    Time.now
        )
        
        # execute
        run_api_test test_result
      end
    end
    
    puts "Finished API Tests"

  end
    
  def run_api_test(test_result)
      
    # on development, if theres a static oauth_token on the config, skip it
    if @config['oauth_token'] and test_result.api_id == 'oauth'
      return
    end
    
    if not current_test or current_test.api_id != test_result.api_id
      puts "\n  API #{test_result.api_name}"
    end
    @current_test = test_result
    method_signature = "run_#{test_result.method_id}"

    # if there's a method to run the API
    if self.respond_to? method_signature
      result = self.send(method_signature, test_result)
      
    # otherwise use the generic one
    else
      result = generic_api_test test_result
    end

    if result == TestResult::PASSED
      puts "\n    - [PASSED] #{test_result['name']}"
    elsif result == TestResult::WARNING
      puts "\n    - [WARNING] #{test_result['name']}"
    else
      puts "\n    - [ERROR] #{test_result['name']}"
    end
    
    # save test result
    test_result.attributes = {
      :finished_at => Time.now,
      :duration =>    (Time.now - test_result.created_at).to_f,
      :result =>      result
    }
    test_result.save
  end
  
  def generic_api_test(test_result)
    test_result.url =     parse_method_values test_result.url
    test_result.headers = parse_method_values test_result.headers
    test_result.data    = parse_method_values test_result.data
    
    is_json = test_result.headers and test_result.headers['Accept'] == 'application/json'
    
    if is_json and test_result.data and not test_result.data.kind_of? String
      test_result.data = JSON.unparse(test_result.data)
    end
    
    if test_result.verb == "POST"
      page = @agent.post(test_result.url, test_result.data, test_result.headers)
    else
      page = @agent.get(test_result.url, test_result.data, nil, test_result.headers)
    end
  
    # Green
    if (200..299) === page.code.to_i
      return TestResult::PASSED 
    end
    
    # Red
    log_error page.body
    return TestResult::ERROR
  
  rescue Exception => e
    return handle_api_error(e)
  end  
  
  def parse_method_values(value)
    if defined?(value)
      if value.kind_of? Hash
        value.each{ |key, item| 
          value[key] = parse_method_values item }
          
      elsif value.kind_of? String
        return value.gsub("{auth_token}",   "Bearer #{@oauth_token}"
          ).gsub("{telephone}",    @config['tel'].to_s
          ).gsub("{short_code}",   @config['short_code'].to_s
          ).gsub("{user_id}",      @config['user_id'].to_s
          ).gsub("{user_password}",@config['password'].to_s
          ).gsub("{client_id}",    @config['api_key']
          ).gsub("{client_secret}",@config['secret_key'])
      end
    end
    
    return value
  end
  
  def handle_api_error(e)
    
    # if it was an interruption, re-raise
    if e.kind_of?(SystemExit) or e.kind_of?(Interrupt)
      raise e
    end
  
    if defined?(e.page) and defined?(e.page.response) and e.page.response['content-type'] == 'application/json'
      result = JSON.parse(e.page.body)

      if result and (result['RequestError'] or result['requestError'])
        log_error e
        return TestResult::WARNING
      end
    end
    
    # Red
    log_error e
    return TestResult::ERROR
  end

  def log_error(msg)
    log = ""
    
    if msg.kind_of?(Exception)
      log = log + msg.inspect + "\n"
      
      if defined?(msg.page) and not msg.page.nil?
        
        puts msg.page.inspect
        
        log = log + msg.page.body  + "\n"
      end
      
      if defined?(msg.backtrace) and not msg.backtrace.nil?
        log = log + msg.backtrace.join("\n") + "\n"
      end
    else 
      log = msg
    end
    
    unless @current_test.nil?
      @current_test.log = log
    end
    
    puts log
  end

end