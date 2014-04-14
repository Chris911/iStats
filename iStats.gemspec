# coding: utf-8
require 'rake'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iStats/version'

spec = Gem::Specification.new do |s|
  s.name          = "iStats"
  s.version       = IStats::VERSION
  s.authors       = ["Chris911"]
  s.email         = ["christophe.naud.dulude@gmail.com"]
  s.description   = "Stats for your mac"
  s.summary       = "Stats for your mac"
  s.homepage      = "https://github.com/Chris911/iStats"
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib", "ext"]

  s.platform = Gem::Platform::RUBY
  s.extensions = FileList["ext/**/extconf.rb"]

  s.add_dependency "sparkr"

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rake-compiler"
end
