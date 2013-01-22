require 'json'
require 'curb'
require 'mechanize'
require 'logger'
require 'pp'
require 'active_support/core_ext'
require 'base64'

require 'yaml'

require './apis/att'
require './apis/oauth'
require './apis/device_capabilities'
require './apis/device_location'
require './apis/payments'
require './apis/sms'
require './apis/mms'
require './apis/mmsv2'
require './apis/notary'
require './apis/wap'
require './apis/speech'

module TestStatus
  GREEN = 1
  YELLOW = 2
  RED = 3
end

class AttApiReporter

  DEBUG_RESP = 3 # Outputs response body
  DEBUG_INFO = 5 # Outputs request URLs
  DEBUG_ALL = 10 # Outputs request / response headers
  
  include AttApi::Oauth
  include AttApi::DeviceCapabilities
  include AttApi::DeviceLocation
  include AttApi::Notary
  include AttApi::Payments
  include AttApi::SMS
  include AttApi::MMS
  include AttApi::MMSv2
  include AttApi::Wap
  include AttApi::Speech

  attr_reader :tests
  
  def initialize(conf)
    @startTime = @lastTime = Time.new
    @localServer = conf[:localServer] || 'http://127.0.0.1:5985'
    @oauth_token = conf[:oauth_token]
    @debug = conf[:debug] || 0
    @shortCode = conf[:shortCode]
    @userID = conf[:userID]
    @password = conf[:password]
    @tel = conf[:tel]

    @testNames = ['oauth_login', 'oauth_gettoken']
    @testResults = {}
    @authorize_failed = false

    @testName = "*****"
    
    raise "No baseURL specified" unless @baseURL = conf[:baseURL]
    raise "No clientID specified" unless @clientID = conf[:clientID]
    raise "No clientSecret specified" unless @clientSecret = conf[:clientSecret]

    @agent = Mechanize.new
    @agent.read_timeout = 300
    @agent.open_timeout = 300
    # @agent.log = Logger.new(STDOUT)

    # parse API definition
    @tests = []
    @test_index = 0
    
    api_definition = JSON.parse IO.read("conf/att-api.json")
    api_definition['apis'].each do |api|
      api['methods'].each do |method|
        method['api_id'] = api['id']
        method['api_name'] = api['name']
        method['method_id'] = method['id']
        method['id'] = "#{method['api_id']}_#{method['method_id']}"
        @tests << method
      end
    end
  end
    
  def run
    puts "\nRunning API Tests"
    next_test
    write_log
  end

  def run_in_thread
    Thread.new { run }
  end

  def next_test
    sleep 3
    test = @tests[@test_index]
    @test_index = @test_index + 1
    
    if test
      
      # on development, if theres a static oauth_token on the config, skip it
      if @oauth_token and test['api_id'] == 'oauth'
        next_test
        return
      end
      
      if not @current_test or @current_test['api_id'] != test['api_id']
        puts "  API #{test['api_name']}"
      end
      
      @current_test = test
      @startTestTime = Time.new
      
      method_signature = "run_#{@current_test['id']}"

      # if there's a method to run the API
      if self.respond_to? method_signature
        result = self.send method_signature
        
      # otherwise use the generic one
      else
        result = test_api test
      end

      if result == TestStatus::GREEN
        puts "    - [GREEN] #{test['name']}"
      elsif result == TestStatus::YELLOW
        puts "    - [YELLOW] #{test['name']}"
      else
        puts "    - [RED] #{test['name']}"
      end
      
      write_log
      log_result(test, result)
      next_test
    else
      
      puts "Finished API Tests"
      
    end
  end

  def test_results
    @testResults
  end

  def test_names
    @testNames
  end

  def base_url
    @baseURL
  end


  def user_id
    @userID
  end

  def password
    @password
  end

  def client_id
    @clientID
  end

  def client_secret
    @clientSecret
  end

  def tel
    @tel
  end

  def client_secret
    @clientSecret
  end

  def short_code
    @shortCode
  end

  def local_server
    @localServer
  end

  
  private
    
    
    def parse_method_values(value)
      if defined?(value)
        if value.kind_of? Hash
          value.each{ |key, item| 
            value[key] = parse_method_values item }
            
        elsif value.kind_of? String
          return value
              .gsub("{auth_token}",   "Bearer #{@oauth_token}")
              .gsub("{telephone}",    @tel.to_s)
              .gsub("{short_code}",   @shortCode.to_s)
              .gsub("{short_code}",   @shortCode.to_s)
              .gsub("{user_id}",      @userID.to_s)
              .gsub("{user_password}",@password.to_s)
              .gsub("{client_id}",    @clientID)
              .gsub("{client_secret}",@clientSecret)
        end
      end
      
      return value
    end
    
    def test_api(method)
      method['url'] = parse_method_values method['url']
      parse_method_values method['headers']
      parse_method_values method['data']
      
      is_json = method['headers'] and method['headers']['Accept'] == 'application/json'
      
      if is_json and method['data'] and not method['data'].kind_of? String
        method['data'] = JSON.unparse(method['data'])
      end
      
      if method['verb'] == "POST"
        page = @agent.post(method['url'], method['data'], method['headers'])
      else
        page = @agent.get(method['url'], method['data'], nil, method['headers'])
      end
    
      # Green
      if (200..299) === page.code.to_i
        return TestStatus::GREEN 
      end
      
      # Red
      log_error page.body
      return TestStatus::RED
    
    rescue Exception => e
      return handle_api_error(e)
    end
    
    def handle_api_error(e)
      if defined?(e.page) and defined?(e.page.response) and e.page.response['content-type'] == 'application/json'
        result = JSON.parse(e.page.body)

        if result and (result['RequestError'] or result['requestError'])
          log_error e
          return TestStatus::YELLOW
        end
      end
      
      # Red
      log_error e
      return TestStatus::RED
    end


    def simple_get_json(url)

      log_error "Request: : #{url}" if @debug >= AttApiReporter::DEBUG_INFO

      begin
        headers = {
          "Accept" => 'application/json', 
          'Content-Type' => 'application/json'
        }
        
        unless @oauth_token.nil?
          headers['Authorization'] = "Bearer #{@oauth_token}"
        end
        
        page = @agent.get(url, nil, nil, headers)
        parsedResponse = JSON.parse(page.body)
        log_error JSON.pretty_generate(parsedResponse) #if @debug >= AttApiReporter::DEBUG_RESP
        
        return parsedResponse
      rescue Exception => e
        log_error e
        return false
      end
    end

    def simple_get_jsonp(url)

      if url =~ /\?/
        url = "#{url}&callback=jsonpCallback"
      else
        url = "#{url}?callback=jsonpCallback"
      end

      log_error "Request: : #{url}" if @debug >= AttApiReporter::DEBUG_INFO

      begin
        page = @agent.get({:url => url, :headers => {"Accept" => 'application/json', 'Content-Type' => 'application/json'}})
        log_error page.body #if @debug >= AttApiReporter::DEBUG_RESP
        return page.body
      rescue Exception => e
        log_error e.backtrace
        log_error e.page.body
        return false
      end

    end

    def simple_get_xml(url)

      log_error "Request: : #{url}" if @debug >= AttApiReporter::DEBUG_INFO

      begin
        page = @agent.get({:url => url, :headers => {"Accept" => 'application/xml', 'Content-Type' => 'application/xml'}})
        log_error page.body #if @debug >= AttApiReporter::DEBUG_RESP
        parsedXml = Hash.from_xml(page.body)
        return parsedXml
      rescue Exception => e
        log_error e.backtrace
        log_error e.page.body
        return false
      end

    end


    def simple_form_post(url, params)

      log_error "Request: #{url}" if @debug >= AttApiReporter::DEBUG_INFO
      begin
        page = @agent.post(url, params)
        parsedBody = JSON.parse(page.body)
        log_error JSON.pretty_generate(parsedBody) #if @debug >= AttApiReporter::DEBUG_RESP
        return parsedBody
      rescue Exception => e
        log_error e.backtrace
        log_error e.page.body
        return false
      end
    end

    def simple_json_post(url, body, headers = {})
      log_error "Request: #{url}" if @debug >= AttApiReporter::DEBUG_INFO
      begin
        page = @agent.post(url, body, {'Accept' => 'application/json', 'Content-Type' => 'application/json'}.merge(headers))
        parsedBody = JSON.parse(page.body)
        log_error JSON.pretty_generate(parsedBody) #if @debug >= AttApiReporter::DEBUG_RESP
        return parsedBody
      rescue Exception => e
        log_error e.backtrace
        log_error e.page.body
        return false
      end
    end

    def simple_jsonp_post(url, body, headers = {})

      if url =~ /\?/
        url = "#{url}&callback=jsonpCallback"
      else
        url = "#{url}?callback=jsonpCallback"
      end

      log_error "Request: #{url}" if @debug >= AttApiReporter::DEBUG_INFO

      begin
        page = @agent.post(url, body, {'Accept' => 'application/json', 'Content-Type' => 'application/json'}.merge(headers))
        parsedBody = JSON.parse(page.body)
        log_error JSON.pretty_generate(parsedBody) #if @debug >= AttApiReporter::DEBUG_RESP
        return parsedBody
      rescue Exception => e
        log_error e.backtrace
        log_error e.page.body
        return false
      end
    end

    def simple_xml_post(url, xmlString)

      log_error "Request: #{url}" if @debug >= AttApiReporter::DEBUG_INFO
      log_error "Sending #{xmlString}"

      begin
        page = @agent.post(url, xmlString, {'Accept' => 'application/xml', 'Content-Type' => 'application/xml'})
        log_error page.body
        parsedXml = Hash.from_xml(page.body)
        return parsedXml
      rescue Exception => e
        log_error e.backtrace
        log_error e.page.body
        return false
      end
    end

    def log(msg, reset = false)
      if reset
        @lastTime = Time.new
      end
      
      puts "#{sprintf("%.1f", Time.now - @lastTime)}s (#{sprintf("%.1f", Time.now - @startTime)}s total) OK. #{msg}..."
      @lastTime = Time.now
    end

    def log_result(test, result)
      testTime = Time.now - @startTestTime;

      File.open("results/#{test['id']}.csv", 'a') {|f| 
        f.write("#{@startTestTime.to_i},#{testTime},#{result}\n") 
      }

      initlogresults
      @testResults[@testName]["apiTime"] = testTime;
      @testResults[@testName]["resultMsg"] = result;
    end

    def initlogresults()
       temp = @testResults[@testName]
        if(!temp)
          temp = {"apiTime" => "","resultMsg" => "", "errors"=> [] }
          @testResults[@testName] = temp
        end
    end

    def log_error(msg)
      initlogresults
      
      if msg.kind_of?(Exception)
        puts msg.inspect
        puts msg.page.body unless msg.page.nil?
        puts msg.backtrace
        msg = msg.inspect
      else 
        puts msg
      end
      
      @testResults[@testName]["errors"] << msg
      write_log
    end

    def write_log()
      File.open("logs/#{@startTime.to_i}.yml", "w") do |f|
         f.write(YAML::dump(@testResults))
       end
    end
end
