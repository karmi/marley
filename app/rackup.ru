$:.unshift File.dirname(__FILE__) + '/sinatra/lib'
require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)
 
require 'application'
run Sinatra.application