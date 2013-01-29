require 'rubygems'
require 'daemons'

pwd = Dir.pwd
Daemons.run_proc('config/runners/api_poller.rb') do
  Dir.chdir(pwd)
  exec "ruby config/runners/api_poller.rb"
end