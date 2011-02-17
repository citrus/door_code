module DoorCode
  class RestrictedAccess
    
    MIN_LENGTH = 3
    MAX_LENGTH = 6
    
    DEFAULT_CODE = '12345'
    
    def initialize app, options={}
      @app = app
      @code = parse_code(options[:code])
    end
    
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

    # Where the magic happens...
    def call env
      # return @app.call(env) if confirmed?
      
      @env = env
      request = Rack::Request.new(env)
      post = request.request_method == 'POST'
      xhr = env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
      path = Rack::Utils.unescape(request.path_info)
      if path.include?('.')
        ext = path.split('.')[-1]
      else
        path = (path[-1] == '/' ? "#{path}index.html" : "#{path}/index.html")
        ext = 'html'
      end
      mime_type = Rack::Mime.mime_type(".#{ext}")
      response = Rack::Response.new
      
      if post
        supplied_code = request.params['code']
        response['Content-Type'] = 'text/javascript' if xhr
        response.write supplied_code == @code ? "success" : "failure"
      else
        if xhr # Means we're trying to fetch the code length
          response["Content-Type"] = 'text/javascript'
          response.write @code.length.to_s
        else
          response["Content-Type"] = mime_type
          begin
            # Find the DoorCode content (restricted to the gem directory)
            response.write ::File.read(::File.dirname(__FILE__) + path)
          rescue # File not found - simply returns basic 404 (need to enhance this)
            response.write '404!'
            response.status = 404
          end
        end
      end
      
      # Render response
      return response.finish
    end
  end
end