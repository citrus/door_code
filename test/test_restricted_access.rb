require 'helper'


class TestRestrictedAccess < Test::Unit::TestCase
  
  include Rack::Test::Methods

  def app
    TestingApp.new
  end
  
  should "require login" do
    get "/"
    
    assert_equal 401, last_response.status
    
    assert last_response.body.include?("Authorized Personnel Only")
    
    
    
    #puts last_response.status
    #puts "----"
    
    #puts last_response.inspect
    
    #assert last_response.status
    #assert last_response.body.include?("Cool")
  end

end