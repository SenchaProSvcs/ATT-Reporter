require 'rubygems'
require 'daemons'

pwd = Dir.pwd
Daemons.run_proc('config/runners/web_app.rb') do
  Dir.chdir(pwd)
  exec "ruby config/runners/web_app.rb"
end