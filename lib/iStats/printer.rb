module IStats
  class Printer
    @display_graphs = true
    @display_labels = true
    @display_scale = true
    @temperature_scale = 'celcius'

    LABEL_WIDTH = 24
    VALUE_WIDTH = 8
    SCALE_WIDTH = 4

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

      def get_temperature_scale
        @temperature_scale
      end

      def set_temperature_scale(scale)
        @temperature_scale = scale
      end

      # Create colored sparkline
      # value      - The stat value
      # thresholds - must be an array of size 4 containing the threshold values
      #              for the sparkline colors
      #
      # If the values in the thresholds array are descending, treat 100% as
      # good (green) instead of bad (red)
      #
      def gen_sparkline(value, thresholds)
        # Graphs can be disabled globally
        return '' unless @display_graphs

        return if thresholds.count < 4

        value = value.to_f

        list = [0, 30, 55, 80, 100, 130]
        sparkline = Sparkr.sparkline(list) do |tick, count, index|
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

      # Converts the value to the class temperature_scale with
      # accompanying scale string.
      #
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

      # Pretty print temperature values.
      # Returns the formatted temperature string.
      #
      def format_temperature(temperature)
          value, scale = Printer.format_temperature(temperature)
          "#{value}#{scale}"
      end

      # Prints a standard item line with label, value, scale, and sparkline
      # as determined by the runtime command-line arguments supplied by the
      # user.
      #
      def print_item_line(label, value, scale="", thresholds=[], suffix="")

        if @display_scale
          full_value_width = VALUE_WIDTH + SCALE_WIDTH
          full_value = value.to_s + scale.to_s
        else
          full_value_width = VALUE_WIDTH
          full_value = value
        end

        if @display_labels
          format = "%-"+LABEL_WIDTH.to_s + "s"
          printf("%-" + LABEL_WIDTH.to_s + "s", label + ": ")
        end

        printf("%-" + full_value_width.to_s + "s", full_value)

        if @display_graphs
          print "#{Printer.gen_sparkline(value, thresholds)}"
        end

        if @display_labels && suffix != ""
          print "  #{suffix}"
        end

        printf "\n"
      end

    end
  end
end
