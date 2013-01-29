require 'rubygems'
require 'daemons'

project_root = File.join(File.dirname(__FILE__), '..', '..')

Daemons.run_proc('api_poller.rb', {
  :log_output => true,
  :dir_mode => :normal,
  :dir => '/tmp/pids'
}) do
  Dir.chdir(project_root)
  exec "ruby config/runners/api_poller.rb"
end