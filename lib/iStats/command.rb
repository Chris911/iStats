module IStats
  # Main point of entry for `istats` command-line tool
  class Command
    class << self
      def execute(*args)
        puts 'Hello, World!'
      end
    end
  end
end
