module IStats
  # Main point of entry for `istats` command-line tool
  class Command
    class << self
      include IStats::Color

      # Executes a command
      #
      def execute
        Settings.load

        options = parse_options

        # Default command is 'all'
        category = ARGV.empty? ? 'all' : ARGV.shift
        stat     = ARGV.empty? ? 'all' : ARGV.shift

        setup options

        delegate(category, stat, options)
      end

      # Setup execution by applying global settings
      #
      # options - command line options
      #
      def setup(options)
        Printer.disable_graphs unless options[:display_graphs]
        Printer.disable_labels unless options[:display_labels]
        Printer.disable_scale unless options[:display_scale]
        Printer.set_temperature_scale options[:temperature_scale]
      end

      # Delegate command to proper class
      #
      # category - Hardware we are targeting (CPU, fan, etc.)
      # stat     - The stat we want
      #
      def delegate(category, stat, options)
        case category
        when 'all'
          all
        when 'cpu'
          Cpu.delegate stat
        when 'fan'
          Fan.delegate stat
        when 'battery'
          Battery.delegate stat
        when 'extra'
          Extra.delegate stat
        when 'scan'
          SMC.delegate stat
        when 'enable'
          Settings.delegate ['enable',stat]
        when 'disable'
          Settings.delegate ['disable',stat]
        when 'list'
          Settings.list
        else
          help("Unknown category: #{category}")
        end
      end

      # Execute all the stats methodes for all modules
      #
      def all
        puts "--- CPU Stats ---\n"
        Cpu.all
        puts "\n--- Fan Stats ---\n"
        Fan.all
        puts "\n--- Battery Stats ---\n"
        Battery.all

        sensors = $config.params
        if sensors.keys.any? {|key| sensors[key]['enabled'] == "1"}
          puts "\n--- Extra Stats ---\n"
          Extra.all
        else
          puts "\nFor more stats run `istats extra` and follow the instructions."
        end
      end

      # Public: Parse extra options
      #
      # returns nothing
      def parse_options
        options = {
          :display_graphs => true,
          :display_labels => true,
          :display_scale => true,
          :temperature_scale => 'celcius',
        }

        opt_parser = OptionParser.new do |opts|
          opts.on('-v', '--version', 'Print Version') do
            puts "iStats v#{IStats::VERSION}"
            quit
          end

          opts.on('-h', '--help', 'Print Help') do
            help
            quit
          end

          opts.on('--no-graphs', 'Don\'t display graphs') do
            options[:display_graphs] = false
          end

          opts.on('--no-labels', 'Don\'t display key names') do
            options[:display_labels] = false
          end

          opts.on('--no-scale', 'Display just the stat value (number-only)') do
            options[:display_scale] = false
          end

          opts.on('--value-only', 'No graph, label, or scale') do
            options[:display_graphs] = false
            options[:display_labels] = false
            options[:display_scale] = false
          end

          opts.on('-f', '--fahrenheit', 'Display temperatures in fahrenheit') do
            options[:temperature_scale] = 'fahrenheit'
          end
        end

        begin
          opt_parser.parse!
          options
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

          istats --help                        This help text
          istats --version                     Print current version

          # Commands
          istats all                           Print all stats
          istats cpu                           Print all CPU stats
          istats cpu [temp | temperature]      Print CPU temperature
          istats fan                           Print all fan stats
          istats fan [speed]                   Print fan speed
          istats battery                       Print all battery stats
          istats battery [health]              Print battery health
          istats battery [time | remain]       Print battery time remaining
          istats battery [cycle_count | cc]    Print battery cycle count info
          istats battery [temp | temperature]  Print battery temperature
          istats battery [charge]              Print battery charge
          istats battery [capacity]            Print battery capacity info

          istats scan                          Scans and print temperatures
          istats scan [key]                    Print single SMC temperature key
          istats scan [zabbix]                 JSON output for Zabbix discovery
          istats enable [key | all]            Enables key
          istats disable [key | all]           Disable key
          istats list                          List available keys

          # Arguments
          --no-graphs                          Don't display sparklines graphs
          --no-labels                          Don't display item names/labels
          --no-scale                           Display just the stat value
          --value-only                         No graph, label, or scale
          -f, --fahrenheit                     Display temperatures in fahrenheit

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
