###
# See README.md
#
# Change the variables below and run `ruby test-oauth.rb`
#    or from the server run 'nohup ruby test-oauth.rb &'
#    then all output will be routed to nohup.out
##

require 'timeout'
require 'rubygems'
require 'sinatra'
require './att_api_reporter'
require './lib/mini_mime'

# make sure the port is different than the main test (test.rb)
configure do
  set :port, 4568
end

def setup

    $reporter = AttApiReporter.new(
      :debug => false, #AttApiReporter::DEBUG_INFO, # Set to false, AttApiReporter::DEBUG_INFO or AttApiReporter::DEBUG_ALL
      :baseURL => "https://api.att.com", # API URL
      
      :clientID => '2f9dc3d895ecdd2eb746e4a8f1ac2e05',
      :clientSecret => 'e19fe3273cd64d6b', 
      
      :userID => 'jaisonw@isoftstone.com', # Auth page email address
      :password => 'welcome1', # Auth page email address

      :tel => "4252334767",
      :shortCode => '22527003', # For SMS replies

      # Assume first argument is an auth_token
      :oauth_token => (ARGV[0] || nil),

      :localServer => 'http://localhost.org:4567',
      :publicServer => 'http://localhost.org:4567'

    )

end


# The reporter needs to run in a thread so the Sinatra app can run concurrently
Thread.new do
  sleep 1 # Wait for a second to allow sinatra to start.

  while true
    setup
    $testsAreRunning = true
    $testsStartTime = Time.new
    $reporter.run_in_thread
    $testsAreRunning = false
    # puts "tests started, next run will be in 5 minutes"
    sleep 300
    puts ""
  end
  # exit
end