Door Code
=========

### Restrict access with a 3-6 digit PIN code.

## Installation

Rubygems:

    (sudo) gem install door_code

Bundler:

    gem 'door_code', '~> 0.0.7'

## Configuration
    
In config.ru or within your Sinatra app:

    use DoorCode::RestrictedAccess, :code => '12345' # code must be 3-6 digits

Optional options:

    use DoorCode::RestrictedAccess,
      :code => '12345', # set a single valid code
      :codes => ['12345','6789'], # set multiple valid codes
      :salt => "my super secret code" # use a custom salt for cookie encryption
    
In application.rb (Rails3) or environment.rb (Rails2):

    config.middleware.use DoorCode::RestrictedAccess, :code => '12345'

## Demo

There is a simple demo application running on Heroku at [http://doorcodedemo.heroku.com](http://doorcodedemo.heroku.com). Log in using the default door code: `12345`

## Notes

* The default code is '12345'
* All options passed to DoorCode are optional. If no valid codes are supplied, the default code will be activated

## To Do

* Allow specifying domains and paths to restrict access conditionally
* API for customization
* Write more tests
