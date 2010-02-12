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
			list = heroku.list
			if list.size > 0
				display list.map {|name, owner|
					if heroku.user == owner
						name
					else
						"#{name.ljust(25)} #{owner}"
					end
				}.join("\n")
			else
				display "You have no apps."
			end
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
			if name = extract_option('--app')
				info = heroku.info(name)
				url  = info[:domain_name] || "http://#{info[:name]}.#{heroku.host}/"
				conf = nil

				display("Permanently destroy #{url} (y/n)? ", false)
				if ask.downcase == 'y'
					heroku.destroy(name)
					if remotes = git_remotes(Dir.pwd)
						remotes.each do |remote_name, remote_app|
							next if name != remote_app
							shell "git remote rm #{remote_name}"
						end
					end
					display "Destroyed #{name}"
				end
			else
				display "Set the app you want to destroy adding --app <app name> to this command"
			end
		end
	end
end
