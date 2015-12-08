# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mitos/version'

Gem::Specification.new do |spec|
  spec.name          = "mitos"
  spec.version       = Mitos::VERSION
  spec.authors       = ["Jonathan Bramble"]
  spec.email         = ["jbramble82@hotmail.com"]

  spec.summary       = "A ruby program to control a mitos syringe pump"
  spec.description   = "This is useful for experimentalist with mitos pumps who need to control their pumps with code - useful for autonomous working"
  spec.homepage      = "http://github.com/jonbramble/mitos"
  #spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "rubyserial"
end
