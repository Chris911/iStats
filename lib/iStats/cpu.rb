  # CPU Stats
# Extend CPU_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class Cpu
    extend CPU_STATS
    class << self

      # Delegate CLI command to function
      #
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

      # Call all functions (stats)
      #
      def all
        cpu_temperature
      end

      # Print CPU temperature with sparkline
      #
      def cpu_temperature
        t = get_cpu_temp
        thresholds = [50, 68, 80, 90]
        puts "CPU temp: #{t}#{Symbols.degree}C  " + Printer.gen_sparkline(t, thresholds)
      end
    end
  end
end
