# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iStats/version'

Gem::Specification.new do |spec|
  spec.name          = "iStats"
  spec.version       = IStats::VERSION
  spec.authors       = ["Chris911"]
  spec.email         = ["christophe.naud.dulude@gmail.com"]
  spec.description   = "Stats for your mac"
  spec.summary       = "Stats for your mac"
  spec.homepage      = "https://github.com/Chris911/iStats"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extensions = FileList["ext/**/extconf.rb"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler"
end
