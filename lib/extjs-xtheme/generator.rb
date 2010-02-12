module ExtJS
  module XTheme
    module Generator
      ##
      # creates a new Sass theme
      # @param {String} name
      # @param {String} ext_dir path to Ext directory relative to public/javascripts
      # @param {String} theme_dir Path to theme output dir (eg: stylesheets/sass)
      #
      def self.create(name, ext_dir, theme_dir)
        ext_css_path  = "#{ext_dir}/resources/css"
        theme_path    = "#{theme_dir}/#{name}"
        
        # Create theme directory in /stylesheets/sass
        FileUtils.mkdir_p ["#{theme_path}/visual", "#{theme_path}/structure"]

        # Create the defines.sass file, set img_path variable.          
        FileUtils.copy("#{File.dirname(__FILE__)}/
        
        
        template/defines.sass", "#{theme_path}defines.sass")  
        defines = File.read("#{theme_path}/defines.sass")
        File.open("#{theme_path}/defines.sass", "w+") {|f| f << defines.gsub(/\{\{img_path\}\}/, "../sass/#{name}/images") }
        puts " - created #{theme_path}/defines.sass"

        sass_files = []
        # Iterate each Ext css file and convert to Sass.
        ["structure", "visual"].each do |subdir|
          puts " Converting #{subdir} styles to Sass"
          Dir["#{ext_css_path}/#{subdir}/*.css"].each do |file|
            m = /^.*\/(.*)\.css$/.match(file)
            sass_file = "#{theme_path}/#{subdir}/#{m.captures[0]}.sass"
            puts " - css2sass #{m.captures[0]}.css -> #{sass_file}"
            sass_files << "@import #{subdir}/#{m.captures[0]}.sass"
            `css2sass #{file} #{sass_file}`
            write_sass_vars(sass_file)
          end
        end

        # Create master sass file, which includes @imports for all other files in theme.
        puts " - Writing init.sass"
        f = File.new("#{theme_path}/init.sass", "w")
        f.puts sass_files.join("\n")

        # Copy Ext theme images to new Sass theme dir.
        FileUtils.cp_r("#{ext_dir}/resources/images/default", "#{theme_path}/images")
      end

      ##
      # performs hsv transformation on Ext theme images and save to Sass theme dir.
      # @param {String} name Theme name
      # @param {String} ext_dir path to Ext directory relative to public/javascripts
      # @param {Float} hue
      # @param {Float} saturation
      # @param {Float} lightneess
      #
      def self.hsv_transform(name, ext_dir, theme_dir, hue=1.0, saturation=1.0, lightness=1.0)    
        theme_path = "#{theme_dir}/#{name}"
        
        each_image(ext_path) {|img|
          write_image(img.modulate(lightness, saturation, hue), theme_path(name))
        }
        # update hue in defines.sass
        defines = File.read("#{theme_path}/defines.sass")
        File.open("#{theme_path}/defines.sass", "w+") {|f| f << defines.gsub(/hue\s?=.*/, "hue = #{(hue-1)*180}") }
      end

    private

      ##
      # Iterate all theme images
      # @param {String} path
      #
      def self.each_image(path)
        Dir["#{path}/*/"].each do |dir|
          Dir[dir+'/*.gif'].each do |filename|
            yield(Magick::ImageList.new(filename))
          end
          Dir[dir+'/*.png'].each do |filename|
            yield(Magick::ImageList.new(filename))
          end
        end
        # Now transform any images left in the base /images/default directory (excluding s.gif)
        Dir["#{path}/*.*"].reject {|f| f.match('s.gif')}.each do |filename|
          yield(Magick::ImageList.new(filename))
        end
      end

      ##
      # Searches .sass file for HEX colors and wraps in Sass adjust_hue function.
      # Also substitutes urls with !img_path Sass var
      # @param {String} filename of .sass file to write !vars to
      #
      def self.write_sass_vars(file)
        sass = File.read(file)
        sass.gsub!(/background-image: url\(\.\.\/images\/default/, 'background-image = url(!img_path')
        sass.gsub!(/\b(.*):\s?#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/, '\1 = adjust_hue(#\2, !hue)')

        # append @import "defines.sass" at start of each .sass file in order to use defined variables
        File.open(file, "w") {|f| f << "@import ../defines.sass\n#{sass}" }
      end

      ##
      # Write transformed RMagick::Image to theme directory
      # @param {RMagick::Image} img
      # @param {String} dest Theme directory
      #
      def self.write_image(img, dest)
        # Get filename and directory
        m = /\/default\/(.*)\/(.*)\.(.*)$/.match(img.filename) || /\/default\/(.*)\.(.*)$/.match(img.filename)
        #m = /\/(.*)\/(.*)\.(.*)$/.match(img.filename) || /\/(.*)\.(.*)$/.match(img.filename)
        outfile = (m.captures.length == 3) ? "#{dest}/images/#{m[1]}#{m[2]}.#{m[3]}" : "#{dest}/images/#{m[1]}.#{m[2]}"

        puts " - #{outfile}"
        img.write(outfile)
      end
    end
  end
end
