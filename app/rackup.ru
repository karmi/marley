require 'sinatra'
 
set :environment, :production
disable :run

log = File.new(File.join( File.dirname(__FILE__), '..', 'log', 'sinatra.log'), "w")
STDOUT.reopen(log)
STDERR.reopen(log)

require 'marley' 
run Sinatra::Application