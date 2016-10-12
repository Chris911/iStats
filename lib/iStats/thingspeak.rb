module IStats
  class Thingspeak
    gem_name, *gem_ver_reqs = 'thingspeak-api', '>0'
    gdep = Gem::Dependency.new(gem_name, *gem_ver_reqs)
    @found_gspec = gdep.matching_specs.max_by(&:version)
    require 'parseconfig'
    @configFile = "thingspeak.conf"
    @configDir = File.expand_path("~/.iStats") + "/"

    class << self

      def delegate(stat)
        load()
        if (stat =~/write-api-key=(.*)/)
          if ($1 == 'clear')
            addSetting('WRITE_API_KEY','')
          else
            addSetting('WRITE_API_KEY',$1)
          end
        elsif (stat =~/read-api-key=(.*)/)
          if ($1 == 'clear')
            addSetting('READ_API_KEY','')
          else
            addSetting('READ_API_KEY',$1)
          end
        elsif (stat =~/channel(\d)=(.*)/)
          if ($1 == 'clear')
            addSetting("CHANNEL"+$1,'')
          else
            addSetting("CHANNEL"+$1,$2)
          end
        else
          sendToThingSpeak()
        end
      end

      def load
        if File.exists?(@configDir + @configFile)
          $thingspeak_config = ParseConfig.new(@configDir + @configFile)
        else
          if !File.exists?(@configDir)
            Dir.mkdir( @configDir)
          end
          file=File.open(@configDir + @configFile,"w+")
          file.close
          $thingspeak_config = ParseConfig.new
        end
      end

      def addSetting(key,value)
        settings = ParseConfig.new(@configDir + @configFile)
        settings.add(key,value)
        file = File.open(@configDir + @configFile,'w')
        settings.write(file)
        file.close
      end

      def sendToThingSpeak()
        if @found_gspec
        require 'thingspeak'
        client = ThingSpeak::Client.new($thingspeak_config["WRITE_API_KEY"], $thingspeak_config["READ_API_KEY"])
        # post an update to your channel, returns the identifier of the new post if successful
        channels =$thingspeak_config.params
        fields={}
        channels.keys.each{ |key|
                  if (key =~/CHANNEL(\d)/)
                    fields.store("field"+$1, SMC.get_supported_key(channels[key]))
                  end
        }
        client.update_channel(fields) # => 3
        else
          puts "gem install thingspeak-api --pre"
        end
      end
    end
  end
end
