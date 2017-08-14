module IStats
  module Utils
    extend self
    
    # Converts a temperature value in celcius to fahrenheit.
    #
    # Returns the temperature in fahrenheit.
    def to_fahrenheit(temperature)
      (temperature * (9.0 / 5.0)) + 32
    end

    # Produce a thresholds array containing absolute values based on supplied
    # percentages applied to a literal max value.
    #
    def abs_thresholds(scale, max_value)
      at = []
      scale.each { |v|
        at.push(v * max_value)
      }
      return at
    end

  end
end
