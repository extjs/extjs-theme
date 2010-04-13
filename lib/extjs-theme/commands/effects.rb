require 'launchy'

module ExtJS::Theme::Command
  class Effects < Base

    def modulate
      unless @args.length == 4
        display "Usage: xtheme effects:modulate <theme-name> <hue> <saturation> <lightness>"
        display " Specify <hue>, <saturation> and <lightness> as Floats, for example,"
        display " 0.25 means 25%. The default value of each argument is 1.0, that is, 100%"
        return
      end
      display "Modulating theme images"
      ExtJS::Theme::Effects.modulate(@config[:ext_dir], "#{@config[:theme_dir]}/#{@args[0]}", @args[1].to_f, @args[2].to_f, @args[3].to_f)
    end
  end
end
