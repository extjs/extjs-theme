module ExtJS::Theme
  module Effects

    ##
    # performs hsv transformation on Ext theme images and save to Sass theme dir.
    # @param {String} name Theme name
    # @param {String} ext_dir path to Ext directory relative to public/javascripts
    # @param {Float} hue
    # @param {Float} saturation
    # @param {Float} lightness
    #
    def self.modulate(ext_dir, theme_dir, hue=1.0, saturation=1.0, lightness=1.0)
      each_image("#{ext_dir}/resources/images/default") {|img|
        write_image(img.modulate(lightness, saturation, hue), theme_dir)
      }
      # update hue in defines.sass
      defines = File.read("#{theme_dir}/defines.sass")
      File.open("#{theme_dir}/defines.sass", "w+") {|f| f << defines.gsub(/hue\s?=.*/, "hue = #{(hue-1)*180}") }
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
