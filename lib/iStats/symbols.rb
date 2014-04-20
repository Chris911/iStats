module IStats
  class Symbols
    class << self

      # Degree symbol
      # This adds support for ruby 1.9 and below
      #
      def degree
        176.chr(Encoding::UTF_8)
      end
    end
  end
end
