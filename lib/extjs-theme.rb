##
# XTheme
# A module for generating and colorizing ExtJS themes.
#
module ExtJS 
  module Theme    
  end
end
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/extjs-theme')

['dependencies', 'generator', 'effects'].each do |file|
  require file
end
