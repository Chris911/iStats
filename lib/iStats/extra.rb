# Extra Stats
# Displays any extra sensors enabled in config
#
module IStats
  class Extra
    extend SMC_INFO
    class << self

      # Delegate CLI command to function
      #
      def delegate(stat)
        if stat == 'all'
          all
        else
          sensor_temperature stat
        end
      end

      # Prints temperature for all enabled keys
      #
      def all
        sensors = $config.params
        display = sensors['AltDisplay']
        if sensors.keys.any? {|key| sensors[key]['enabled'] == "1"}
          sensors.keys.each{ |key|
            if (sensors[key]['enabled'] == "1")
              extra_enabled = true
              display_temp(key, sensors[key], display)
            end
          }
        else
          puts "Looks like you don't have any extra keys enabled. \nRun `istats scan` for the initial scan or `istats --help` for more info."
        end
      end

      # Prints temperature for specific key
      #
      def sensor_temperature(key)
        sensors = $config.params
        display = sensors['AltDisplay']
        sensor = sensors[key]
        if sensor.nil?
          Command.help "Unknown sensor: #{stat}"
        else
          display_temp(key, sensor, display)
        end
      end

      # Pretty print sensor temperature
      def display_temp(key, sensor, display)
        t = SMC.is_key_supported(key).round(2);
        value, scale = Printer.parse_temperature(t)

        thresholds = sensor['thresholds'][1..-2].split(/, /).map { |s| s.to_i }

        if Printer.get_temperature_scale == 'fahrenheit'
          thresholds.map! { |t| Utils.to_fahrenheit(t) }
        end

        if (display)
          # Invoked if settings has an AltDisplay?
          puts "#{Printer.format_label("#{key}")}" +
               "#{Printer.format_temperature(t)}#{Printer.gen_sparkline(t, thresholds)}" +
               "#{Printer.format_label(" #{sensor['name']}")}"
        else
          Printer.print_item_line("#{key} #{sensor['name']} temp", value, scale, thresholds)
        end
      end
    end
  end
end
