module IStats
  class Printer
    @display_graphs = true
    @display_labels = true
    @display_scale = true
    @temperature_scale = 'celcius'

    class << self
      include IStats::Color

      def disable_graphs
        @display_graphs = false
      end

      def disable_labels
        @display_labels = false
      end

      def disable_scale
        @display_scale = false
      end

      def set_temperature_scale(scale)
        @temperature_scale = scale
      end

      # Create colored sparkline
      # value      - The stat value
      # thresholds - must be an array of size 4 containing the threshold values
      #              for the sparkline colors
      #
      def gen_sparkline(value, thresholds)
        # Graphs can be disabled globally
        return '' unless @display_graphs

        return if thresholds.count < 4

		value = value.to_f

        list = [0, 30, 55, 80, 100, 130]
        sparkline = "\t" + Sparkr.sparkline(list) do |tick, count, index|
          if index.between?(0, 5) and value > thresholds[3]
            flash_red(tick)
          elsif index.between?(0, 1)
            green(tick)
          elsif index.between?(2, 3) and value > thresholds[0]
            light_yellow(tick)
          elsif index == 4 and value > thresholds[1]
            yellow(tick)
          elsif index == 5 and value > thresholds[2]
            red(tick)
          else
            tick
          end
        end
      end

      def format_label(label)
        if @display_labels == true
          "#{label}\t"
        end
      end

      def format_scale(scale)
        if @display_scale == true
          "#{scale}"
        end
      end

      # Pretty print temperature values.
      # Also converts the value to the class temperature_scale.
      #
      # Returns the temperature string.
      def parse_temperature(temperature)
        if @temperature_scale == 'celcius'
          value = temperature
          symbol = "C"
        else
          value = Utils.to_fahrenheit(temperature)
          symbol = "F"
        end

        return value.round(2), "#{Symbols.degree}#{symbol}"
      end

      def format_temperature(temperature)
          value, scale = Printer.format_temperature(temperature)
          "#{value}#{scale}"
      end

      def print_item_line(label, value, scale="", thresholds=[], suffix="")
        if @display_labels
          print "#{label}:\t"
        end

        print value

        if @display_scale
          print scale
        end

        if @display_graphs
          print "\t#{Printer.gen_sparkline(value, thresholds)}"
        end

        if @display_labels
          print "\t#{suffix}"
        end

        printf "\n"
      end

    end
  end
end
