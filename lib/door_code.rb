module DoorCode
  class RestrictedAccess
    
    MIN_LENGTH = 3
    MAX_LENGTH = 6
    
    DEFAULT_CODE = '12345'
    
    def initialize app, options={}
      @app = app
      @code = parse_code(options[:code])
    end
    
    # Ensures the code is good & valid, otherwise
    # reverts to the default
    def parse_code code
      parsed_code = code.gsub(/\D/, '')
      if parsed_code == code
        # Means the supplied code contains only digits, which is good
        # Just need to check that the code length is valid
        parsed_code = DEFAULT_CODE if code.length < MIN_LENGTH || code.length > MAX_LENGTH
      else
        # Means the supplied code contained non-digits, so revert to default
        parsed_code = DEFAULT_CODE
      end
      parsed_code
    end
    
    def cookie_name
      'door_code'
    end
    
    # Rack::Request wrapper around @env
    def request
      @request ||= Rack::Request.new(@env)
    end
    
    # Rack::Response object with which to respond with
    def response
      @response ||= Rack::Response.new
    end
    
    # Is the request verb POST?
    def post?
      request.request_method == 'POST'
    end
    
    # Was the request called via AJAX?
    def xhr?
      @env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    end
    
    # Code supplied from user
    def supplied_code
      request.params['code']
    end
    
    # Is the supplied code vaid for the current area
    def valid_code? code
      @code == code
    end
    
    # Check if the supplied code is valid;
    # Either sets a confirming cookie and Success message
    # or delete any door code cookie and set Failure message
    def validate_code!
      valid_code?(supplied_code) ? confirm! : unconfirm!
    end
    
    # Is there a valid code for the area set in the cookie
    def confirmed?
      request.cookies[cookie_name] && valid_code?(request.cookies[cookie_name])
    end
    
    # Set a cookie for the correct value (server value may change)
    # Also set up Success message
    def confirm!
      response.write 'success'
      response.set_cookie(cookie_name, {:value => supplied_code, :path => "/"})
    end
    
    # Delete and invalid cookies
    # Also set up Failure message
    def unconfirm!
      response.write 'failure'
      response.delete_cookie(supplied_code)
    end
    
    def code_length
      @code.length.to_s
    end
    
    def build_rack_objects
      @request = Rack::Request.new(@env)
      @response = Rack::Response.new
    end

    # Where the magic happens...
    def call env
      @env = env
      build_rack_objects
      
      return @app.call(env) if confirmed?
      p 'Loading DoorCode::RestrictedAccess'
      
      if post?
        supplied_code = request.params['code']
        response['Content-Type'] = 'text/javascript' if xhr?
        validate_code! # Validate the user's code and set a cookie if valid
      else
        index = ::File.read(::File.dirname(__FILE__) + '/index.html')
        index_with_code_length = index.gsub(/\{\{codeLength\}\}/, code_length)
        response.write index_with_code_length
      end
      
      # Render response
      return response.finish
    end
  end
end