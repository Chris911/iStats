# Fan Stats
# Extend BATTERY_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class Battery
    extend BATTERY_STATS
    class << self

      # Delegate CLI command to function
      #
      def delegate(stat)
        case stat
        when 'all'
          all
        when 'temp', 'temperature'
          battery_temperature
        when 'health'
          battery_health
        when 'cycle_count', 'cc'
          cycle_count
        when 'time', 'remain'
          battery_time_remaining
        when 'charge'
          battery_charge
        else
          Command.help "Unknown stat for Battery: #{stat}"
        end
      end

      # Call all functions (stats)
      #
      def all
        battery_health
        battery_temperature
        battery_time_remaining
        battery_charge
        cycle_count
      end

      # Prints the battery cycle count info
      #
      def cycle_count
        data = %x( ioreg -l | grep Capacity )
        cycle_count = data[/"Cycle Count"=([0-9]*)/, 1]
        if cycle_count == nil
          puts "Cycle count: unknown"
        else
          max_cycle_count = design_cycle_count
          percentage = (cycle_count.to_f/max_cycle_count.to_f)*100
          thresholds = [45, 65, 85, 95]
          puts "Cycle count: #{cycle_count}  " + Printer.gen_sparkline(percentage, thresholds)
          puts "Max cycle count: #{max_cycle_count}"
        end
      end

      # Get the battery temperature
      #
      def battery_temperature
        puts "Battery temp: #{get_battery_temp.round(2)}#{Symbols.degree}C  "
      end

      # Get the battery health
      # Calls a C method from BATTERY_STATS module
      #
      def battery_health
        puts "Battery health: #{get_battery_health}"
      end

      def battery_time_remaining
        result = case get_battery_time_remaining
        when String
          get_battery_time_remaining
        when Integer
          seconds = get_battery_time_remaining
          hours   = get_battery_time_remaining / 3600
          minutes = get_battery_time_remaining / 60 - hours * 60

          "%i:%02i" % [hours, minutes]
        end

        puts "Battery time remaining: #{result}"
      end

      def battery_charge
        puts "Battery charge: #{get_battery_charge}%"
      end

      # Get the battery design cycle count
      # Calls a C method from BATTERY_STATS module
      #
      def design_cycle_count
        get_battery_design_cycle_count
      end
    end
  end
end
