module DoorCode
  
  class << self
    
    def salt
      @salt ||= generate_random_salt
    end
    
    # Generate a random salt for the encryption
    def generate_random_salt
      o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
      string = (0..50).map{ o[rand(o.length)]  }.join
    end
    
  end

  class RestrictedAccess
    
    MIN_LENGTH = 3
    MAX_LENGTH = 6
    
    DEFAULT_CODE = '12345'
    
    def initialize app, options={}
      @app = app
      # The code or codes can be supplied as either a single string or an array using either
      # the ":code" or ":codes" key. ":codes" trumps ":code" if both are supplied
      @codes = options[:codes] ? parse_codes(options[:codes]) : parse_codes(options[:code])
    end
    
    # Filters the supplied codes to ensure they are valid, and sets the DEFAULT_CODE if no
    # valid codes are detected
    def parse_codes(codes)
      parsed_codes = codes.respond_to?(:any?) ? codes.map { |c| parse_code(c) } : [parse_code(codes)]
      # If there are any valid codes supplied which are unique and valid, 
      # strip the default code out in order to circumvent a security hole
      if parsed_codes.compact.uniq.empty?
        parsed_codes << DEFAULT_CODE
        p "DoorCode: no valid codes detected - activating default code"
      end
      parsed_codes.compact.uniq.map { |c| Digest::SHA1.hexdigest("--#{salt}--#{c}--") }
    end
    
    # Checks that the code provided is valid, returning nil if not
    def parse_code(code)
      parsed_code = code.to_s.gsub(/\D/, '')
      if parsed_code == code && (code.length < MIN_LENGTH || code.length > MAX_LENGTH)
        # Means the supplied code contains only digits, which is good
        # Just need to check that the code length is valid
        parsed_code = nil
        p "DoorCode: invalid PIN code detected"
      elsif parsed_code != code
        # Means the supplied code contained non-digits, so revert to default
        parsed_code = nil
        p "DoorCode: invalid PIN code detected"
      end
      parsed_code
    end
    
    # 
    def salt
      @salt ||= DoorCode.salt
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
    
    # Encrypted code supplied from user
    def supplied_code
      Digest::SHA1.hexdigest("--#{salt}--#{request.params['code']}--")
    end
    
    # Is the supplied code valid for the current area
    def valid_code?(code)
      @codes.include?(code)
    end
    
    # Check if the supplied code is valid;
    # Either sets a confirming cookie and Success message
    # or delete any door code cookie and set Failure message
    def validate_code!
      valid_code?(supplied_code) ? confirm! : unconfirm!
    end
    
    # Is there a valid code for the area set in the cookie
    def confirmed?
      cookied_code && valid_code?(cookied_code)
    end
    
    # Set a cookie for the correct value (server value may change)
    # Also set up Success message
    def confirm!
      request.xhr? ? response.write('success') : response.redirect('/')
      response.set_cookie(cookie_name, { :value => supplied_code, :path => "/", :expire_after => (24*60*60) })
    end
    
    # Delete and invalid cookies
    # Also set up Failure message
    def unconfirm!
      request.xhr? ? response.write('failure') : response.redirect('/')
      response.delete_cookie(supplied_code)
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
      p 'DoorCode: Unauthorized personnel detected'
      
      if request.post?
        response['Content-Type'] = 'text/javascript' if request.xhr?
        validate_code! # Validate the user's code and set a cookie if valid
      else
        
        # Set request status to Unauthorized
        #response.status = 401
    
        index = ::File.read(::File.dirname(__FILE__) + '/index.html')
        response.write index
      end
            
      # Render response
      return response.finish
    end
  end
end