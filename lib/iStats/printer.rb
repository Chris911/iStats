module IStats
  class Printer
    @display_graphs = true

    class << self
      include IStats::Color

      def disable_graphs
        @display_graphs = false
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

        list = [0, 30, 55, 80, 100, 130]
        sparkline = Sparkr.sparkline(list) do |tick, count, index|
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
    end
  end
end
