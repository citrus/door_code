Door Code
=========

### Restrict access with a 3-6 digit PIN code.

## Installation

Rubygems:

    (sudo) gem install door_code

Bundler:

    gem 'door_code', '~> 0.0.3'

### Then
    
In config.ru:

    use DoorCode::RestrictedAccess, :code => '12345'
  
    # to use a custom salt for cookie encryption
    
    use DoorCode::RestrictedAccess, :code => '12345', :salt => "my super secret code"
  
    
    
In application.rb (Rails3) or environment.rb (Rails2):

    config.middleware.use DoorCode::RestrictedAccess, :code => '12345'

## Demo

There is a simple demo application running on Heroku at [http://doorcodedemo.heroku.com](http://doorcodedemo.heroku.com). Log in using the default door code: `12345`

## Notes

* The default code is '12345'
* If the code passed to DoorCode is invalid (eg contains non-digits), the default code will be assigned

## To Do

* Allow specifying domains and paths to restrict access conditionally
* Write more tests
