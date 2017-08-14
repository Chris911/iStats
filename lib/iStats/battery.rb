# Fan Stats
# Extend BATTERY_STATS C module (ext/osx_stats/smc.c)
#
module IStats
  class Battery
    extend BATTERY_STATS
    class << self

      # Delegate CLI command to function
      #
      def delegate(stat)
        # Before we deletage check if there's a battery on system
        return unless validate_battery

        case stat
        when 'all'
          all
        when 'temp', 'temperature'
          battery_temperature
        when 'health'
          battery_health
        when 'cycle_count', 'cc'
          cycle_count
        when 'time', 'remain'
          battery_time_remaining
        when 'charge'
          battery_charge
        when 'capacity'
          print_capacity_info
        else
          Command.help "Unknown stat for Battery: #{stat}"
        end
      end

      # Call all functions (stats)
      #
      def all
        return unless validate_battery

        battery_health
        cycle_count
        print_capacity_info
        battery_temperature
      end

      # Prints the battery cycle count info
      #
      def cycle_count
        @ioreg_out ||= %x( ioreg -rn AppleSmartBattery )
        cycle_count = @ioreg_out[/"CycleCount" = ([0-9]*)/, 1]
        if cycle_count == nil
          Printer.print_item_line("Cycle count", "unknown")
        else
          max_cycle_count = design_cycle_count
          percentage = (cycle_count.to_f/max_cycle_count.to_f)*100
          thresholds = Utils.abs_thresholds([0.45, 0.65, 0.85, 0.95], max_cycle_count)

          Printer.print_item_line("Cycle count", cycle_count, "", thresholds, "#{percentage.round(1)}%")
          Printer.print_item_line("Max cycles", max_cycle_count)
        end
      end

      # Get information from ioreg
      #
      def grep_ioreg(keyword)
        @ioreg_out ||= %x( ioreg -rn AppleSmartBattery )
        capacity = @ioreg_out[/"#{keyword}" = ([0-9]*)/, 1]
      end

      # Original max capacity
      #
      def ori_max_capacity
        grep_ioreg("DesignCapacity")
      end

      # Current max capacity
      #
      def cur_max_capacity
        grep_ioreg("MaxCapacity")
      end

      # Current capacity
      #
      def cur_capacity
        grep_ioreg("CurrentCapacity")
      end

      # Print battery capacity info
      #
      def print_capacity_info
        cur_max = cur_max_capacity.to_f
        ori_max = ori_max_capacity.to_f

        percentage = (cur_max / ori_max)*100

        per_thresholds = [0.95, 0.85, 0.65, 0.45]
        cur_thresholds = Utils.abs_thresholds(per_thresholds, cur_max)
        ori_thresholds = Utils.abs_thresholds(per_thresholds, ori_max)

        charge = get_battery_charge
        result = charge ? "#{charge}%" : "Unknown"
        Printer.print_item_line("Current charge", cur_capacity, " mAh", cur_thresholds, "#{result}")
        Printer.print_item_line("Maximum charge", cur_max_capacity, " mAh", ori_thresholds, "#{percentage.round(1)}%")
        Printer.print_item_line("Design capacity", ori_max_capacity, " mAh")
      end

      # Get the battery temperature
      #
      def battery_temperature
        value, scale = Printer.parse_temperature(get_battery_temp)
        Printer.print_item_line("Battery temp", value, scale)
      end

      # Get the battery health
      # Calls a C method from BATTERY_STATS module
      #
      def battery_health
        Printer.print_item_line("Battery health", get_battery_health)
      end

      def battery_time_remaining
        time = get_battery_time_remaining

        if time.is_a? Integer
          hours   = time / 3600
          minutes = time / 60 - hours * 60

          time = "%i:%02i" % [hours, minutes]
        end

        Printer.print_item_line("Battery time remaining", time)
      end

      def battery_charge
        charge = get_battery_charge
        result = charge ? charge : "Unknown"
        Printer.print_item_line("Battery charge", result, "%")
      end

      # Get the battery design cycle count
      # Calls a C method from BATTERY_STATS module
      #
      def design_cycle_count
        get_battery_design_cycle_count
      end

      # Check if there's a battery on the system
      #
      def validate_battery
        valid = has_battery?
        puts 'No battery on system' unless valid
        valid
      end
    end
  end
end
