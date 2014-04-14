# Extensions (C libs)
require 'osx_stats'

# Gems
require 'optparse'
require 'sparkr'

# Internal
require 'iStats/version'
require 'iStats/color'
require 'iStats/command'
require 'iStats/cpu'

module IStats
  def self.options
    @options ||= {}
  end
end
