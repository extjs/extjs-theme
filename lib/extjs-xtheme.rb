##
# XTheme
# A module for generating and colorizing ExtJS themes.
#
module ExtJS 
  module XTheme    
  end
end
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/extjs-xtheme')

['dependencies', 'generator', 'effects'].each do |file|
  require file
end
