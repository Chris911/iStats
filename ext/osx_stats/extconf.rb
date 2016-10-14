require 'mkmf'
require 'rbconfig'
include RbConfig

case CONFIG['host_os']
  when /mswin|windows/i
    # Windows
  when /linux|arch/i
  require 'iStats/linux_stats'
         # Linux
  when /sunos|solaris/i
    # Solaris
  when /darwin/i
    extension_name = 'osx_stats'

CONFIG['LDSHARED'] << ' -framework IOKit -framework CoreFoundation '

# The destination
dir_config(extension_name)

# Do the work
create_makefile(extension_name)

    #MAC OS X
  else
    # whatever
end
