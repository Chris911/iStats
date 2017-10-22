# Extensions (C libs)
require 'osx_stats'

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

  def self.get_info
  	{
  		battery_health_stats: Battery.get_battery_health_info,
		battery_charge_stats: Battery.get_battery_charge_info,
		cpu_temperature: Cpu.temperature,
		cpu_thresholds: Cpu.thresholds,
		fan_numbers_and_speeds: Fan.get_fan_speeds
  	}
  end
end
