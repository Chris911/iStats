module IStats
  module Utils
    extend self
    
    # Converts a temperature value in celcius to fahrenheit.
    #
    # Returns the temperature in fahrenheit.
    def to_fahrenheit(temperature)
      (temperature * (9.0 / 5.0)) + 32
    end
  end
end
