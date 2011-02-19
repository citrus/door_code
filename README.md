Door Code
=========

### Restrict access with a 3-6 digit PIN code.

## Installation

Via Rubygems:

    (sudo) gem install door_code

Install with Bundler:

    gem 'door_code', '0.0.1', :git => 'http://github.com/6twenty/door_code.git'
    
In config.ru:

    use DoorCode::RestrictedAccess, :code => '12345'
    
Or in application.rb (Rails3) or environment.rb (Rails2):

    config.middleware.use DoorCode::RestrictedAccess, :code => '12345'

## Demo

There is a simple demo application running on Heroku at http://doorcodedemo.heroku.com. Log in using the default door code; 12345.

## Notes

* The default code is '12345'
* If the code passed to DoorCode is invalid (eg contains non-digits), the default code will be assigned

## To Do

* Write tests
* Add HELP function (explains how the keypad works)
* Allow specifying domains and paths to restrict access conditionally
* Add no-js/no-base64 version
* Add favicon?
