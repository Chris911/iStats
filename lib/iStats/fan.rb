module IStats
  # Fan Stats
  # Extend FAN_STATS C module (ext/osx_stats/smc.c)
  class Fan
    extend FAN_STATS
    class << self
      include IStats::Color

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

      def all
        print_fan_number
        fans_speed
      end

      def fan_number
        # C method
        get_fan_number
      end

      def print_fan_number
        puts "Total fans on system: #{fan_number}"
      end

      def fans_speed
        fanNum = fan_number
        (0..(fanNum-1)).each do |n|
          s = get_fan_speed(0)
          print_fan_speed(n, s)
        end
      end

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
