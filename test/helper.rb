ENV["environment"] = "test"

require 'test/unit'
require 'rack/test'
require 'shoulda'
require 'door_code'
require 'sinatra/base'


class TestingApp < Sinatra::Base

  use DoorCode::RestrictedAccess, :code => '12345'

  get '/' do
    'The Coolness'
  end
  
  get '/logout' do
    response.delete_cookie('door_code')
    redirect '/'
  end
  
end