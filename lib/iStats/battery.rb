# Fan Stats
# Extend BATTERY_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class Battery
    extend BATTERY_STATS
    class << self
      include IStats::Color

      # Delegate CLI command to function
      #
      def delegate(stat)
        case stat
        when 'all'
          all
        when 'health'
          battery_health
        when 'cycle_count', 'cc'
          cycle_count
        else
          Command.help "Unknown stat for Battery: #{stat}"
        end
      end

      # Call all functions (stats)
      #
      def all
        battery_health
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

          list = [0, 30, 55, 80, 100, 130]
          sparkline = Sparkr.sparkline(list) do |tick, count, index|
            if index.between?(0, 5) and percentage > 95
              flash_red(tick)
            elsif index.between?(0, 1)
              green(tick)
            elsif index.between?(2, 3) and percentage > 45
              light_yellow(tick)
            elsif index == 4 and percentage > 65
              yellow(tick)
            elsif index == 5 and percentage > 85
              red(tick)
            else
              tick
            end
          end
          puts "Cycle count: #{cycle_count} " + sparkline
          puts "Max cycle count: #{max_cycle_count}"
        end
      end

      # Get the battery health
      # Calls a C method from BATTERY_STATS module
      #
      def battery_health
        puts "Battery health: #{get_battery_health}"
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
