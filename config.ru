require 'bundler'
Bundler.require

require './app'

Dotenv.load

run Sinatra::Application
