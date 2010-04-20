require 'test_helper'
FileUtils.cd("test")

PUBLIC_PATH = "public"
THEME_PATH = File.join(PUBLIC_PATH, "stylesheets", "themes")

# Remove previously generated config and test theme before starting.
FileUtils.rm("config/xtheme.yml") if File.exists?("config/xtheme.yml")
FileUtils.rm_r(File.join(THEME_PATH, "foo")) if File.exists?(File.join(THEME_PATH, "foo"))

class ThemeTest < Test::Unit::TestCase  
  context "Within a valid Rails-like app" do
    setup {
      `xtheme init public/javascripts/ext-3.x #{THEME_PATH}`
    }
  
    should "config/xtheme.yml should exist" do
      assert File.exists?("config/xtheme.yml"), "Failed to create config/xtheme.yml"
    end
    
    should "generate a theme" do
      `xtheme create foo`
      assert (
        File.exists?(File.join(THEME_PATH, "foo", "all.sass")) &&
        File.exists?(File.join(THEME_PATH, "foo", "images", "rails.png")) &&
        File.exists?(File.join(THEME_PATH, "foo", "structure", "structure.sass")) &&
        File.exists?(File.join(THEME_PATH, "foo", "visual", "visual.sass"))
      ), "Failed to generate theme"
    end
    
    should "modulate a theme" do
      # first destroy existing default image.
      an_image = File.join(THEME_PATH, "foo", "images", "rails.png")
      FileUtils.rm(an_image)
      
      # run the effect, it should create a newly modulated version of image (it should be green but how to tell?).
      `xtheme effects:modulate foo 1.5 1.0 1.0`
      
      assert File.exists?(an_image), "Failed to modulate images"
    end
  end
end
