module IStats
  # CPU Stats
  # Extend CPU_STATS C module (ext/osx_stats/smc.c)
  class Cpu
    extend CPU_STATS
    class << self
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
        puts "CPU temp: #{get_cpu_temp}°C"
      end
    end
  end
end
