require 'launchy'

module ExtJS::XTheme::Command
	class Theme < Base
	  
	  def init
	    
	    unless args.length == 2
	      display "Usage: xtheme init <path/to/ext> <path/to/stylesheets>"
	      display " - Eg: xtheme init public/javascripts/ext-3.1.0 public/stylesheets"
	      return
	    end
	    
	    unless File.directory?(args[0])
	      return display "Error: invalid path/to/ext #{args[0]}"
	    end
	    unless File.directory?(args[1])
	      return display "Error: invalid path/to/stylesheets #{args[1]}"
	    end
	    
      display "Initializing xtheme configuration file .xthemeconfig"
      
      File.open(".xthemeconfig", "w+") {|f| 
        f << {
          :ext_dir => args[0],
          :theme_dir => "#{args[1]}/sass"
        }.to_yaml
      }
    end
	  
		def list
			display "Not implemented"
		end

		def create
			name    = args.shift.downcase.strip rescue nil
			if !name
			  return display "Usage: xtheme create <name>"
			end
			ExtJS::XTheme::Generator.create(name, @config[:ext_dir], @config[:theme_dir])
			display "Created #{name}"
			
		end

		def destroy
			display "Not implemented"
		end
	end
end
