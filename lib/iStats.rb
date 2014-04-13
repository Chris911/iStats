# Extensions (C libs)
require 'osx_stats/osx_stats'

# Gems
require 'optparse'

# Internal
require 'iStats/version'
require 'iStats/command'
require 'iStats/cpu'

module IStats
  def self.options
    @options ||= {}
  end
end
