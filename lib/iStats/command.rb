module IStats
  # Main point of entry for `istats` command-line tool
  class Command
    class << self
      include IStats::Color

      def execute(*args)
        # Default command is 'all'
        category = args.empty? ? 'all' : args.shift
        stat     = args.empty? ? 'all' : args.shift

        parse_options
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

      # Public: Parse extra options
      #
      # returns nothing
      def parse_options
        o = OptionParser.new do |opts|
          opts.on('-v', '--version', 'Print Version') do
            puts "iStats v#{IStats::VERSION}"
            quit
          end
          opts.on('-h', '--help', 'Print Help') do
            help
            quit
          end
        end
        begin
          o.parse!
        rescue OptionParser::MissingArgument => e
          help e.message
          quit
        rescue OptionParser::InvalidOption => e
          help e.message
          quit
        end
      end

      # Public: Prints help.
      #
      # Returns nothing.
      def help(error = nil)
        text =
        " #{error.nil? ? '' : red("\n[Error] #{error}\n")}
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

      # Public: Quit / Exit program
      #
      # Returns nothing
      def quit
        exit(1)
      end
    end
  end
end
