# SMC
# Extend CPU_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class SMC
    require 'json'
    extend SMC_INFO
    class << self
      # Delegate CLI command to function
      #
      def delegate(stat)
        case stat
        when 'all'
          all
        when 'zabbix'
          zabbix_discover
        else
          scan_supported_key(stat)
        end
      end

      # Call all functions (stats)
      #
      def all
        scan_supported_keys
      end

      def name(key)
        sensors_name = {
          'TA0P' => 'Ambient temperature',
          'TA0p' => 'Ambient temperature',
          'TA1P' => 'Ambient temperature',
          'TA1p' => 'Ambient temperature',
          'TA0S' => 'PCI Slot 1 Pos 1',
          'TA1S' => 'PCI Slot 1 Pos 2',
          'TA2S' => 'PCI Slot 2 Pos 1',
          'TA3S' => 'PCI Slot 2 Pos 2',
          'Tb0P' => 'BLC Proximity',
          'TB0T' => 'Battery TS_MAX',
          'TB1T' => 'Battery 1',
          'TB2T' => 'Battery 2',
          'TB3T' => 'Battery 3',
          'TC0C' => 'CPU 0 Core',
          'TC0D' => 'CPU 0 Die',
          'TCXC' => 'PECI CPU',
          'TCXc' => 'PECI CPU',
          'TC0E' => 'CPU 0 ??',
          'TC0F' => 'CPU 0 ??',
          'TC0G' => 'CPU 0 ??',
          'TC0H' => 'CPU 0 Heatsink',
          'TC0J' => 'CPU 0 ??',
          'TC0P' => 'CPU 0 Proximity',
          'TC0c' => '',
          'TC0d' => '',
          'TC0p' => '',
          'TC1C' => 'Core 1',
          'TC1c' => '',
          'TC2C' => 'Core 2',
          'TC2c' => '',
          'TC3C' => 'Core 3',
          'TC3c' => '',
          'TC4C' => 'Core 4',
          'TC5C' => 'Core 5',
          'TC6C' => 'Core 6',
          'TC7C' => 'Core 7',
          'TC8C' => 'Core 8',
          'TCGC' => 'PECI GPU',
          'TCGc' => 'PECI GPU',
          'TCPG' => '',
          'TCSC' => 'PECI SA',
          'TCSc' => 'PECI SA',
          'TCSA' => 'PECI SA',
          'TG0H' => 'GPU 0 Heatsink',
          'TG0P' => 'GPU 0 Proximity',
          'TG0D' => 'GPU 0 Die',
          'TG1D' => 'GPU 1 Die',
          'TG1H' => 'GPU 1 Heatsink',
          'TH0P' => 'Harddisk 0 Proximity',
          'Th1H' => 'NB/CPU/GPU HeatPipe 1 Proximity',
          'TL0P' => 'LCD Proximity',
          'TM0P' => 'Memory Slot Proximity',
          'TM0S' => 'Memory Slot 1',
          'Tm0p' => 'Misc (clock chip) Proximity',
          'TO0P' => 'Optical Drive Proximity',
          'Tp0P' => 'PowerSupply Proximity',
          'TPCD' => 'Platform Controller Hub Die',
          'TS0C' => 'Expansion slots',
          'Ts0P' => 'Palm rest L',
          'Ts0S' => 'Memory Bank Proximity',
          'Ts1p' => 'Palm rest R',
          'TW0P' => 'AirPort Proximity'
        }

        return sensors_name.fetch(key,"Unknown")

      end
      # Print temperature with sparkline
      #
      def scan_supported_keys
        sensors = Hash.new
        Settings.configFileExists

        puts "Scanning keys...\n\n"

        characters = [('a'..'z'), ('A'..'Z'),(0..9)].map { |i| i.to_a }.flatten
        characters.each {|l1|
          characters.each {|l2|
            characters.each {|l3|
              key = "T#{l1}#{l2}#{l3}"
              t = is_key_supported(key);
              if (t != 0.0)
                thresholds = [50, 68, 80, 90]
                if Printer.get_temperature_scale == 'fahrenheit'
                  thresholds.map! { |t| Utils.to_fahrenheit(t) }
                end
                sensors['thresholds'] = thresholds
                sensors['name'] = name(key)
                sensors['enabled'] = 0

                Settings.addSensor(key, sensors)
                value, scale = Printer.parse_temperature(t)

                Printer.print_item_line("#{key} #{sensors['name']}", value, scale, sensors['thresholds'])
              end
            }
          }
        }
        puts "\nDone scanning keys.\n"
        puts "All keys are disabled by default. Use `istats enable [key]` to enable specific keys or `istats enable all`."
        puts "The enabled sensors will show up when running `istats` or `istats extra`."
      end

      def zabbix_discover
        items = []

        characters = [('a'..'z'), ('A'..'Z'),(0..9)].map { |i| i.to_a }.flatten
        characters.each {|l1|
          characters.each {|l2|
            characters.each {|l3|
              key = "T#{l1}#{l2}#{l3}"
              if (name(key) != 'Unknown') && (name(key) != '')
                t = is_key_supported(key);
                if (t > 0)
                  item = {'{#KEY}' => key, '{#NAME}' => name(key)}
                  items.push(item)
                end
              end
            }
          }
        }

        data = {:data => items}
        puts JSON.generate(data)
      end

      def scan_supported_key(key)
        t = is_key_supported(key)
        puts "#{Printer.format_label("Scanned #{key} result = ")}#{t}";
      end
    end
  end
end
