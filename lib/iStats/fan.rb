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
        when 'speed'
          fan_speed
        else
          Command.help "Unknown stat for Fan: #{stat}"
        end
      end

      def all
        fan_speed
      end

      def fan_speed
        s = get_fan_speed
        message = "Fan speed: #{s} RPM  "
        list = [0, 30, 55, 80, 100, 130]
        sparkline = Sparkr.sparkline(list) do |tick, count, index|
          if index.between?(0, 5) and s > 5500
            flash_red(tick)
          elsif index.between?(0, 1)
            green(tick)
          elsif index.between?(2, 3) and s > 2500
            light_yellow(tick)
          elsif index == 4 and s > 3500
            yellow(tick)
          elsif index == 5 and s > 4500
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
