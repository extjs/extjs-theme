module ExtJS
  module Theme
    class CLI < Thor
      include Thor::Actions
      
      ARGV = ::ARGV.dup
      
      ##
      # Required by thor
      # Defines the source root-directory when copying files.
      #
      def self.source_root
        ExtJS::Theme["ext_dir"]
      end
      
      desc "init <path/to/ext> <path/to/stylesheets/sass-dir>", "Initialize extjs-theme for the current application.  Creates config/xtheme.yml"
      def init (ext_dir = ExtJS::Theme::DEFAULT_EXT_DIR, theme_dir = ExtJS::Theme::DEFAULT_THEME_DIR)
        empty_directory("config") unless File.exists?("config")
        inside("config") do
          create_file("xtheme.yml", {
            "ext_dir" => ext_dir,
            "theme_dir" => theme_dir
          }.to_yaml) 
        end        
      end
        
      desc "create <theme-name>", "Creates a new sass-theme"
      def create(name)
        self.class.source_root
        
        ext_css_path  = File.join(ExtJS::Theme["ext_dir"], "resources", "css")
        theme_path    = File.join(ExtJS::Theme["theme_dir"], name)
        
        # Create theme directory in /stylesheets/sass
        FileUtils.mkdir_p ["#{theme_path}/visual", "#{theme_path}/structure"]
        
        inside theme_path do
          # load the defines.sass template file
          data = File.read(File.join(File.dirname(__FILE__), "template", "defines.sass"))
          img_path = theme_path.split("/")
          img_path.shift  # get rid of /public bit
          
          # replace img_path sass_var with the location of theme's image-path
          data.gsub!(/\{\{img_path\}\}/, File.join("/", img_path.join('/'), "images"))
          
          # write contents to defines.sass
          sass_files = [];
          create_file("defines.sass", data, :force => true)
          ["structure", "visual"].each do |subdir|
            inside subdir do 
              Dir["#{self.class.source_root}/resources/css/#{subdir}/*.css"].each do |file|
                m = /^.*\/(.*)\.css$/.match(file)
                sass_file = "#{m.captures[0]}.sass"
                sass_files << "@import '#{File.join(subdir, sass_file)}'"
                create_file(sass_file, ExtJS::Theme.css2sass(file), {:force => true})
              end
            end
          end
          create_file("all.sass", sass_files.join("\n"), {:force => true})
          empty_directory("images")
          FileUtils.cp_r("#{self.class.source_root}/resources/images/default/.", "images")
        end
      end
      
      desc "modulate <theme> <hue> <saturation> <lightness>", "Modulate a theme. Specify h, s, l as floats, eg: 1.5"
      def modulate(theme, hue, saturation, lightness)
        ExtJS::Theme.each_image {|img|
          path = img.filename.split('/')
          filename = path.pop
          dir = path.pop
          say_status("modulate", File.join(dir, filename))
          ExtJS::Theme.write_image(img.modulate(lightness.to_f, saturation.to_f, hue.to_f), File.join(ExtJS::Theme["theme_dir"], theme))
        }
        gsub_file(File.join(ExtJS::Theme["theme_dir"], theme, "defines.sass"), /\$hue:\s?(.*)/, "$hue: #{(hue.to_f-1)*180}")
      end
    end
  end
end