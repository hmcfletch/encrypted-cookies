# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "encrypted-cookies/version"

Gem::Specification.new do |s|
  s.name        = "encrypted-cookies"
  s.version     = EncryptedCookies::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Les Fletcher"]
  s.email       = ["les.fletcher@gmail.com"]
  s.homepage    = "http://github.com/hmcfletch/encrypted-cookies"
  s.summary     = %q{Encrypted cookies for Rails 3}
  s.description = %q{Add an encrypted cookie jar for Rails 3 that can be chained with permanent and signed cookies}

  s.rubyforge_project = "encrypted-cookies"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('test-unit', '>= 2.2.0')
  s.add_dependency('activesupport', '~> 3.0')
  s.add_dependency('actionpack', '~> 3.0')

  # note actionpack has requirement bug in 3.0.4 so tests don't run
  # https://rails.lighthouseapp.com/projects/8994/tickets/6393-action_dispatchhttprequestrb-missing-a-require
end
