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
          'TA0P' => 'Ambient temperature',
          'TB0T' => 'Battery Temperature',
          'TA0p' => 'Ambient temperature',
          'TA1P' => 'Ambient temperature',
          'TA1p' => 'Ambient temperature',
          'TC0C' => 'CPU_DIE_CORE_TEMPERATUE Digital',
          'TC0D' => 'CPU_DIE_CORE_TEMPERATUE Digital',
          'TC0E' => '',
          'TC0F' => '',
          'TC0G' => '',
          'TC0J' => '',
          'TC0P' => 'CPU_PROXIMITY_TEMPERATURE',
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
          'TG0H' => '',
          'TG0P' => '',
          'TG0T' => '',
          'Th1H' => 'NB/CPU/GPU HeatPipe 1 Proximity',
          'TM0P' => 'FBDIMM Riser A incoming air Temp',
          'Tm0p' => 'Misc (clock chip) Proximity',
          'Ts0P' => 'Palm rest L',
          'Ts1p' => 'Palm rest R'

        }

        sensors=Hash.new
        
       Settings.configFileExists
       puts "Scanning keys"
        
        characters = [('a'..'z'), ('A'..'Z'),(0..9)].map { |i| i.to_a }.flatten
        characters.each {|l1|
          characters.each {|l2|
            characters.each {|l3|
              key="T#{l1}#{l2}#{l3}"
              t=is_key_supported(key);
              if (t != 0.0)
                sensors['thresholds'] = [50, 68, 80, 90]
                name=temp_sensors_name.fetch(key,"UNKNOWN")
                sensors['name']=name
                sensors['enabled']=0
                
                Settings.addSensor(key,sensors)

                puts "#{key} #{name}  #{t}#{Symbols.degree}C  " + Printer.gen_sparkline(t, sensors['thresholds'])
              end
            }
          }
        }
       puts "All keys are disabled by default. Use istats set [key] to enable" 
      end

      def scan_supported_key(key)
        t = is_key_supported(key)
        puts " Scanned #{key} result = #{t}";
      end
    end
  end
end
