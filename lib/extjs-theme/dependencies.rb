begin
  gem 'haml-edge', '>= 2.3.0'
  $stderr.puts "Loading haml-edge gem."
  
  gem 'rmagick'
  $stderr.puts "Loading rmagick gem."
  
rescue Exception
  #pass
end

require 'sass'
require 'rmagick'



