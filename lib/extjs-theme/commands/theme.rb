require 'yaml'

module ExtJS::Theme::Command
  class Theme < Base

    def init

      ext_path = args[0] || 'public/javascripts/ext-3.2.0'
      theme_path = args[1] || 'app/stylesheets/themes'

      unless File.directory?(ext_path)
        return display "Error: invalid path/to/ext #{ext_path}"
      end
      unless File.directory?(theme_path)
        return display "Error: invalid path/to/stylesheets #{theme_path}"
      end

      display "Initializing xtheme configuration file config/xtheme.yml"

      File.open("config/xtheme.yml", "w+") {|f|
        f << {
                :ext_dir => ext_path,
                :theme_dir => theme_path
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
      ExtJS::Theme::Generator.create(name, @config[:ext_dir], @config[:theme_dir])
      display "Created #{name}"

    end

    def destroy
      display "Not implemented"
    end
  end
end
