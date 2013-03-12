# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roast/version'

Gem::Specification.new do |spec|
  spec.name          = "roast"
  spec.version       = Roast::VERSION
  spec.authors       = ["blahed"]
  spec.email         = ["tdunn13@gmail.com"]
  spec.description   = "Roast is a simple /etc/hosts entry manager"
  spec.summary       = "Roast helps you group and manage entries in your hosts file"
  spec.homepage      = "https://github.com/blahed/roast/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 3.0.0'
  spec.add_development_dependency 'rake'
end
