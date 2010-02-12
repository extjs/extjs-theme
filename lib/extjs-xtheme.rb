##
# XTheme
# A module for generating and colorizing ExtJS themes.
#
module ExtJS 
  module XTheme    
  end
end
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/extjs-xtheme')

['dependencies', 'generator'].each do |file|
  require file
end

#require 'rubygems/command_manager'
#require 'commands/abstract_command'

#%w[migrate owner push tumble webhook].each do |command|
#  require "commands/#{command}"
#  Gem::CommandManager.instance.register_command command.to_sym
#end
