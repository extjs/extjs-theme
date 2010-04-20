begin
  gem 'haml-edge', '>= 2.3.0'
  $stderr.puts "Loading haml-edge gem."
rescue LoadError
  #pass
end

begin
  gem 'rmagick'
  $stderr.puts "Loading rmagick gem."

rescue LoadError
  #pass
end

require 'sass'
require 'RMagick'

