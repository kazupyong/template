require 'bundler'
Bundler.require

class Workbench < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    sass_options = {:cache_location => "/tmp/sass-cache"}
  end

  get '/' do
    @title = 'Index'
    slim :index
  end

  get '/css/application.css' do
    sass :application
  end

  get '/js/application.js' do
    coffee :application
  end
end