require 'sensors'
require 'ap'

module A
@@data=Hash[Sensors.chips.map {|chip|
  [chip.name, Hash[chip.features.map {|feature|
    [feature.label, Hash[feature.subfeatures.map {|subfeature|
      [subfeature.name, subfeature.value]
    }]]
  }]]
}]

def data 
 @@data
end

end
module BATTERY_STATS
def has_battery?
return false
end

end
module FAN_STATS
include A

def get_fan_number
A::data.each do |key, value|

return value.count{|k, _| k =~ /fan\d?\z/}
end
end

def get_fan_speed(fan)
A::data.each do |key, value|
begin	
fan_values=value.fetch("fan#{fan+1}")
rescue
return 0
end
return fan_values.fetch("fan#{fan+1}_input")
end



end

end

module CPU_STATS
include A
def get_cpu_temp
	A::data.each do |key, value|
  		temp1= value.fetch("temp1")  
	return temp1.fetch("temp1_input")
end

end
end

include A
#include CPU_STATS
#get_cpu_temp
