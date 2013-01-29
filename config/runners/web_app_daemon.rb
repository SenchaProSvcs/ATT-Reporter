require 'rubygems'
require 'daemons'

project_root = File.join(File.dirname(__FILE__), '..', '..')

Daemons.run_proc('web_app.rb', {
  :log_output => true,
  :dir_mode => :normal,
  :dir => '/tmp/pids'
}) do
  Dir.chdir(project_root)
  exec "ruby config/runners/web_app.rb"
end