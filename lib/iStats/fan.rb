# Fan Stats
# Extend FAN_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class Fan
    extend FAN_STATS
    class << self
      include IStats::Color

      # Delegate CLI command to function
      #
      def delegate(stat)
        case stat
        when 'all'
          all
        when 'number', 'num'
          print_fan_number
        when 'speed'
          fans_speed
        else
          Command.help "Unknown stat for Fan: #{stat}"
        end
      end

      # Call all functions (stats)
      #
      def all
        print_fan_number
        fans_speed
      end

      # Get the number of fans on system
      # Calls a C method from FAN_STATS module
      #
      def fan_number
        get_fan_number
      end

      # Print number of fan(s)
      #
      def print_fan_number
        puts "Total fans in system: #{fan_number}"
      end

      # Get and print the speed of each fan
      #
      def fans_speed
        fanNum = fan_number
        (0..(fanNum-1)).each do |n|
          s = get_fan_speed(n)
          print_fan_speed(n, s)
        end
      end

      # Actually print fan speed with Sparkline
      # TODO: Move sparkline function to printer class
      #
      # fanNum - The fan number
      # speed  - Fan speed in RPM
      #
      def print_fan_speed(fanNum, speed)
        message = "Fan #{fanNum} speed: #{speed} RPM  "
        list = [0, 30, 55, 80, 100, 130]
        sparkline = Sparkr.sparkline(list) do |tick, count, index|
          if index.between?(0, 5) and speed > 5500
            flash_red(tick)
          elsif index.between?(0, 1)
            green(tick)
          elsif index.between?(2, 3) and speed > 2500
            light_yellow(tick)
          elsif index == 4 and speed > 3500
            yellow(tick)
          elsif index == 5 and speed > 4500
            red(tick)
          else
            tick
          end
        end
        puts message + sparkline
      end
    end
  end
end
