module IStats
  # CPU Stats
  # Extend CPU_STATS C module (ext/osx_stats/smc.c)
  class Cpu
    extend CPU_STATS
    class << self
      include IStats::Color

      def delegate(stat)
        case stat
        when 'all'
          all
        when 'temp', 'temperature'
          cpu_temperature
        else
          Command.help "Unknown stat for CPU: #{stat}"
        end
      end

      def all
        cpu_temperature
      end

      def cpu_temperature
        t = get_cpu_temp
        message = "CPU temp: #{t}#{Symbols.degree}C  "
        list = [0, 30, 55, 80, 100, 130]
        sparkline = Sparkr.sparkline(list) do |tick, count, index|
          if index.between?(0, 5) and t > 90
            flash_red(tick)
          elsif index.between?(0, 1)
            green(tick)
          elsif index.between?(2, 3) and t > 50
            light_yellow(tick)
          elsif index == 4 and t > 68
            yellow(tick)
          elsif index == 5 and t > 80
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
