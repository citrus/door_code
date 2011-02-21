# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "door_code"
  s.version     = '0.0.4'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Fulcher", "Alex Neill", "Spencer Steffen"]
  s.email       = ["mike@plan9design.co.uk", "alex.neill@gmail.com", "spencer@citrusme.com"]
  s.homepage    = "https://github.com/6twenty/door_code"
  s.summary     = %q{Restrict access to your site with a 3-6 digit PIN code}
  s.description = %q{Rack middleware which requires that visitors to the site enter a 3-6 digit PIN code to gain access.}

  s.rubyforge_project = "door_code"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # Runtime
  s.add_runtime_dependency 'rack'
  
  s.add_development_dependency 'shoulda', '2.11.3'
  s.add_development_dependency 'rack-test', '0.5.7'
  
end
