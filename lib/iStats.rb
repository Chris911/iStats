# Extensions (C libs)
require 'osx_stats'

# Gems
require 'optparse'
require 'sparkr'

# Internal
require 'iStats/version'
require 'iStats/color'
require 'iStats/symbols'
require 'iStats/command'
require 'iStats/cpu'
require 'iStats/fan'

module IStats
  def self.options
    @options ||= {}
  end
end
