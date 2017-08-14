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
      # If the values in the thresholds array are descending, treat 100& as 
      # good (green) instead of bad (red)
      #
      def gen_sparkline(value, thresholds)
        # Graphs can be disabled globally
        return '' unless @display_graphs

        return if thresholds.count < 4

        value = value.to_f

        list = [0, 30, 55, 80, 100, 130]
        sparkline = "\t" + Sparkr.sparkline(list) do |tick, count, index|
          if thresholds[3] > thresholds[0]
            #
            # Normal sparkline where 100% is bad
            #
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
          else
            #
            # Reversed sparkline where 100% is good
            #
            if value < thresholds[3]
              if index == 1
                red(tick)
              else
                tick
              end
            elsif value < thresholds[2]
              if index.between?(0, 2)
                yellow(tick)
              else
                tick
              end
            elsif value < thresholds[1]
              if index.between?(0, 3)
                light_yellow(tick)
              else
                tick
              end
            elsif value < thresholds[0]
              if index.between?(0, 4)
                green(tick)
              else
                tick
              end
            else
              green(tick)
            end
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
