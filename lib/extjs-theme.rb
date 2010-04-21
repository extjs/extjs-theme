##
# XTheme
# A module for generating and colorizing ExtJS themes.
#
require 'fileutils'
require 'yaml'
require 'thor'
require 'thor/group'
require 'sass'
require 'sass/css'
require 'RMagick'

module ExtJS
  module Theme
    ROOT = File.dirname(__FILE__)
    
    DEFAULT_EXT_DIR = "public/javascripts/ext-3.2"
    DEFAULT_THEME_DIR = "public/stylesheets/themes"
    
    ##
    # Define Error classes
    #
    class Error < StandardError
      def self.status_code(code = nil)
        return @code unless code
        @code = code
      end

      def status_code
        self.class.status_code
      end
    end
    
    class ArgumentError < Error; status_code(1); end
    class ConfigurationNotFound < Error; status_code(2); end
    class ConfigurationError < Error; status_code(3); end
    
    ##
    # Class Methods
    #
    class << self
      
      ##
      # Xtheme config accessor
      #
      def [](key)
        (@config ||= configure)[key]
      end
      
      ##
      # Convert css file to sass
      # @param {String} file The css filename to convert to sass
      # @return {String}
      #
      def css2sass(file)
        sass = Sass::CSS.new(File.read(file)).render
        sass.gsub!(/background-image: url\(\.\.\/images\/default(.*)\)/, 'background-image: url (#{$img_path+"\1"})')        
        sass.gsub!(/(.*):\s?#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})/, '\1: adjust_hue(#\2, $hue)')
        "@import '../defines.sass'\n#{sass}"
      end
      
      ##
      # Iterate all theme images and yield Magick::ImageList 
      #
      def each_image
        path = File.join(self['ext_dir'], "resources", "images", "default")
        
        Dir["#{path}/*"].each do |dir|
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
      def write_image(img, dest)
        # Get filename and directory.  
        # Need to know if we're writing to /images/<package>/filename.gif OR /images/filename.gif
        m = /\/default\/(.*)\/(.*)\.(.*)$/.match(img.filename) || /\/default\/(.*)\.(.*)$/.match(img.filename)
        outfile = (m.captures.length == 3) ? File.join(dest, "images", m[1], "#{m[2]}.#{m[3]}") : File.join(dest, "images", "#{m[1]}.#{m[2]}")
        img.write(outfile)
      end
      
      private
      
      def configure
        unless File.exists?("config/xtheme.yml")
          raise ConfigurationNotFound.new('This command must be run from inside a valid application')
        end
        cfg = YAML.load_file("config/xtheme.yml")
        cfg["ext_dir"] = File.expand_path(cfg["ext_dir"])
        cfg
      end
    end
  end
end
