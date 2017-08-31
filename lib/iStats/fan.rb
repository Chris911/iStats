# Fan Stats
# Extend FAN_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class Fan
    extend FAN_STATS
    class << self

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
        Printer.print_item_line("Total fans in system", fan_number)
      end

      # Get and print the speed of each fan
      #
      def fans_speed
        fanNum = fan_number
        (0..(fanNum-1)).each do |n|
          s = get_fan_speed(n)
          s = s.round unless s.nil?
          print_fan_speed(n, s)
        end
      end

      # Actually print fan speed with Sparkline
      #
      # fanNum - The fan number
      # speed  - Fan speed in RPM
      #
      def print_fan_speed(fanNum, speed)
        thresholds = [2500, 3500, 4500, 5500]
        Printer.print_item_line("Fan #{fanNum} speed", speed, " RPM", thresholds)
      end
    end
  end
end
