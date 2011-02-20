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
    def parse_code(code)
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
    
    # Name of the cookie
    def cookie_name
      'door_code'
    end
    
    # Returns the value of the saved cookie
    def cookied_code
      request.cookies[cookie_name]
    end
    
    # Rack::Request wrapper around @env
    def request
      @request ||= Rack::Request.new(@env)
    end
    
    # Rack::Response object with which to respond with
    def response
      @response ||= Rack::Response.new
    end
    
    # Code supplied from user
    def supplied_code
      request.params['code']
    end
    
    # Is the supplied code valid for the current area
    def valid_code?(code)
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
  
      p "--" * 88
      print 'xhr?: '
      p request.xhr?
      
    
      cookied_code && valid_code?(cookied_code)
    end
    
    # Set a cookie for the correct value (server value may change)
    # Also set up Success message
    def confirm!
      request.xhr? ? response.write('success') : response.redirect('/')
      response.set_cookie(cookie_name, { :value => supplied_code, :path => "/" })
    end
    
    # Delete and invalid cookies
    # Also set up Failure message
    def unconfirm!
      request.xhr? ? response.write('failure') : response.redirect('/')
      response.delete_cookie(supplied_code)
    end
    
    # Returns the length of the valid code
    def code_length
      @code.length.to_s
    end
    
    # Creates instances of Rack::Request and Rack::Response
    def build_rack_objects
      @request = Rack::Request.new(@env)
      @response = Rack::Response.new
    end

    # Where the magic happens...
    def call(env)
      @env = env
      build_rack_objects
      
      return @app.call(env) if confirmed?
      p 'Loading DoorCode::RestrictedAccess'
      
      if request.post?
        response['Content-Type'] = 'text/javascript' if request.xhr?
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