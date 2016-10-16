# Extensions (C libs)
require 'rbconfig'
include RbConfig

case CONFIG['host_os']
  when /mswin|windows/i
    # Windows
  when /linux|arch/i
  require 'iStats/linux_stats' 
	 # Linux
  when /sunos|solaris/i
    # Solaris
  when /darwin/i
    require 'osx_stats'
    #MAC OS X
  else
    # whatever
end

# Gems
require 'optparse'
require 'sparkr'

# Internal
require 'iStats/version'
require 'iStats/color'
require 'iStats/symbols'
require 'iStats/printer'
require 'iStats/command'
require 'iStats/cpu'
require 'iStats/fan'
require 'iStats/battery'
require 'iStats/extra'
require 'iStats/smc'
require 'iStats/settings'
require 'iStats/utils'

module IStats
  def self.options
    @options ||= {}
  end
end
