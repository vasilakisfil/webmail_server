$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'webmail_server/version'


Gem::Specification.new do |s|
  s.name          = "agrimi"
  s.version       = "0.0.0"
  s.authors       = ["Filippos Vasilakis, Vasileios Panopoulos"]
  s.email         = ["fvas@kth.se, vpan@kth.se"]

  s.summary       = "A simple webmail server"
  s.description   = ""
  s.homepage      = ""


  s.add_development_dependency "rspec"
end
