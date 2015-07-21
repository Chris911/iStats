module IStats
  class Settings
    require 'parseconfig'
    @configFile="sensors.conf"
    @configDir=File.expand_path("~/.iStats")+"/"

    class << self

      def delegate(key)
        add(key)
      end


      def load

        if File.exists?( @configDir+@configFile )
          $config = ParseConfig.new(@configDir+@configFile)
        else
           sensors=Hash.new
           sensors['thresholds'] = "[50, 68, 80, 90]"
           name="CPU Proximity"
           sensors['name']=name
           sensors['enabled']="1"
           key="TC0P"
           $config =ParseConfig.new
           $config.add(key,sensors)
        end
      end

      def configFileExists
         if File.exists?( @configDir+@configFile )
          $config = ParseConfig.new(@configDir+@configFile)
        else
          puts "No config file #{@configDir}#{@configFile} found .. Run scan"
          if !File.exists?(@configDir)
            Dir.mkdir( @configDir)
          end
          file=File.open(@configDir+@configFile,"w+")
          file.close
        end
      end
  
      def addSensor(key,sensors)
        settings = ParseConfig.new(@configDir+@configFile)
        settings.add(key,sensors)
        file = File.open(@configDir+@configFile,'w')
        settings.write(file)
        file.close
      end
      
      def add(key)
        configFileExists
        settings = ParseConfig.new(@configDir+@configFile)
        sensors =settings.params
        if (sensors[key])
          if (sensors[key]['enabled']== "0")
            puts "Enabling key "+key
            sensors[key]['enabled']="1"
          else
            puts "key already enabled"
          end
        else
          puts "Not valid key"
        end
        file = File.open(@configDir+@configFile,'w')
        settings.write(file)
        file.close
      end
      
      def list
        settings = ParseConfig.new(@configDir+@configFile)
        settings.params.keys.each{|key|
          puts key+" => "+SMC.name(key)+" Enabled = "+settings[key]['enabled']
          }
      end
      
    end
  end
end