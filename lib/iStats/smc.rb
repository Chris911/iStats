# SMC 
# Extend CPU_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class SMC
    extend SMC_INFO
    class << self
      # Delegate CLI command to function
      #
      def delegate(stat)
        case stat
        when 'all'
          all
        else
          scan_supported_key(stat)
        end
      end

      # Call all functions (stats)
      #
      def all
        scan_supported_keys
      end

      # Print temperature with sparkline
      #
      def scan_supported_keys

        temp_sensors_name={
          'TA0P' => 'Ambient temperature',  ##MACBOOK PRO
          'TB0T' => '',                      ##MACBOOK PRO
          'TA0p' => 'Ambient temperature',
          'TA1P' => 'Ambient temperature',
          'TA1p' => 'Ambient temperature',
          'TC0C' => 'CPU_DIE_CORE_TEMPERATUE Digital',
          'TC0D' => 'CPU_DIE_CORE_TEMPERATUE Digital', #MACBOOK PRO
          'TC0E' => '',
          'TC0F' => '',
          'TC0G' => '',
          'TC0J' => '',
          'TC0P' => 'CPU_PROXIMITY_TEMPERATURE', #MACBOOK PRO
          'TC0c' => '',
          'TC0d' => '',
          'TC0p' => '',
          'TC1C' => 'CORE 1',
          'TC1c' => '',
          'TC2C' => 'CORE 2',
          'TC2c' => '',
          'TC3C' => '',
          'TC3c' => '',
          'TCGC' => '',
          'TCGc' => '',
          'TCPG' => '',
          'TCSC' => '',
          'TG0H' => '', #MACBOOK PRO
          'TG0P' => '', #MACBOOK PRO
          'TG0T' => ''  #MACBOOK PRO

        }

        (0..35).map{|i| i.to_s 36}.each {|l1|
        (0..35).map{|i| i.to_s 36}.each {|l2|
          (0..35).map{|i| i.to_s 36}.each {|l3|
              key="T#{l1}#{l2}#{l3}".upcase
              t=is_key_supported(key);
              if (t != 0.0)
                thresholds = [50, 68, 80, 90]
                name=temp_sensors_name.fetch(key,"UNKNOWN")
                puts "#{key} #{name}  #{t}#{Symbols.degree}C  " + Printer.gen_sparkline(t, thresholds)
              end
            }
          }
        }
      end

      def scan_supported_key(key)
        t = is_key_supported(key)
        puts " Scanned #{key} result = #{t}";
      end
    end
  end
end
