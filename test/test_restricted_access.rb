require 'helper'

# '12345' encrypted with the default salt
DEFAULT_CODE = Digest::SHA1.hexdigest("--#{DoorCode.salt}--#{DoorCode::RestrictedAccess::DEFAULT_CODE}--")

class TestRestrictedAccess < Test::Unit::TestCase
  
  include Rack::Test::Methods

  def app
    TestingApp.new
  end
  
  def setup
    clear_cookies
  end
    
  should "require login" do
    get "/"
    assert_equal 200, last_response.status
    assert last_response.body.include?("Authorized Personnel Only")
  end

  should "validate login" do
    post "/", { "code" => "12345" }
    assert_equal 302, last_response.status
    
    follow_redirect!    
    
    assert_equal 200, last_response.status
    assert last_response.body.include?("Logged In")
    assert_equal DEFAULT_CODE, rack_mock_session.cookie_jar['door_code']
  end


  context "when cookie exists" do

    setup do
      set_cookie("door_code=#{DEFAULT_CODE}")
    end
  
    should "allow authorized cookies" do
      get "/"
      assert_equal 200, last_response.status
      assert last_response.body.include?("Logged In")
    end
  
    should "logout clearing cookie" do
      get "/logout"
      assert_equal 302, last_response.status
      
      follow_redirect!
    
      assert_equal 200, last_response.status
      assert last_response.body.include?("Authorized Personnel Only")
    end
    
  end
end