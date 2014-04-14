require 'bundler/gem_tasks'
require 'rake/extensiontask'

GEMSPEC = Gem::Specification.load(File.expand_path("../iStats.gemspec", __FILE__))

Rake::ExtensionTask.new('osx_stats', GEMSPEC) do |ext|
  ext.name    = 'osx_stats'
  ext.lib_dir = 'lib/osx_stats'
end
