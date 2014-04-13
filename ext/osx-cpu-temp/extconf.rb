require 'mkmf'

extension_name = 'osx_cpu_temp'

# The destination
dir_config(extension_name)

# Do the work
create_makefile(extension_name)
