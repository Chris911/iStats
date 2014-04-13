module IStats
  # Main point of entry for `istats` command-line tool
  class Command
    class << self

      def execute(*args)
        # Default command is 'all'
        category = args.empty? ? 'all' : args.shift
        stat     = args.empty? ? 'all' : args.shift

        delegate(category, stat)
      end

      def delegate(category, stat)
        case category
        when 'all'
          all
        when 'cpu'
          Cpu.delegate stat
        else
          help("Unknown category: #{category}")
        end
      end

      def all
        # Exec all
        Cpu.all
      end

      # Public: Prints help.
      #
      # Returns nothing.
      def help(error = nil)
        text =
        " #{error.nil? ? '' : "\n[Error] #{error}\n"}
          - iStats: help ---------------------------------------------------

          istats --help                            This help text
          istats --version                         Print current version

          istats all                               Print all stats
          istats cpu                               Print all CPU stats
          istats cpu [temp | temperature]          Print CPU temperature

          for more help see: https://github.com/Chris911/iStats
        ".gsub(/^ {8}/, '') # strip the first eight spaces of every line

        puts text
      end
    end
  end
end
