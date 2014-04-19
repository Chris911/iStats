require 'mkmf'

extension_name = 'osx_stats'

CONFIG['LDSHARED'] << ' -framework IOKit -framework CoreFoundation '

# The destination
dir_config(extension_name)

# Do the work
create_makefile(extension_name)
