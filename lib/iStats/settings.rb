module IStats
  class Settings
    require 'parseconfig'
    @configFile="sensors.conf"
    @configDir=File.expand_path("~/.iStats")+"/"

    class << self
      def load

        if File.exists?( @configDir+@configFile )
          $config = ParseConfig.new(@configDir+@configFile)

        else
          puts "No config file #{@configDir}#{@configFile} found"
          if !File.exists?(@configDir)
            Dir.mkdir( @configDir)
          end
          file=File.open(@configDir+@configFile,"w+")
          file.close
          puts "Running scan"
          SMC.scan_supported_keys
          $config = ParseConfig.new(@configDir+@configFile)

        end
      end

      def addSensor(key,sensors)
        settings = ParseConfig.new(@configDir+@configFile)
        settings.add(key,sensors)
        file = File.open(@configDir+@configFile,'w')
        settings.write(file)
        file.close
      end
      
    end
  end
end