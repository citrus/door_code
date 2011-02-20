ENV["environment"] = "test"

require 'test/unit'
require 'rack/test'
require 'shoulda'
require 'door_code'
require 'sinatra/base'


module Rack
  module Test
    DEFAULT_HOST='localhost'
  end
end

class TestingApp < Sinatra::Base

  #set :sessions, false

  use DoorCode::RestrictedAccess, :code => '12345'

  get '/' do
    'Logged In!'
  end
  
  get '/logout' do
    response.delete_cookie('door_code')
    redirect '/'
  end
  
end