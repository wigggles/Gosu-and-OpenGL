#!/usr/bin/env ruby
#=====================================================================================================================================================
# Additional tutorials and usefull information.
#   https://github.com/vaiorabbit/ruby-opengl
#   http://larskanis.github.io/opengl/tutorial.html
#=====================================================================================================================================================
puts "\n" * 3 # some top buffer for terminal notifications.
puts "*" * 70
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# https://www.codecademy.com/articles/ruby-command-line-argv
APP_NAME = 'Desktop Garage'
case ARGV.first
when 'debug'
  puts "#{APP_NAME} is in debug mode."
end
#-----------------------------------------------------------------------------------------------------------------------------------------------------
ROOT = File.expand_path('.',__dir__)
puts "starting up..."
# Gem used for OS window management and display libs as well as User input call backs.
require 'gosu'    # https://rubygems.org/gems/gosu
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# OpenGL pre-requiries.
require 'opengl'  # https://rubygems.org/gems/opengl-bindings
require 'glu'
OpenGL.load_lib
GLU.load_lib
include OpenGL, GLU
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# System wide vairable settings.
require "#{ROOT}/Konfigure.rb"
include Konfigure # inclusion of CONSTANT settings system wide.

#=====================================================================================================================================================
# Load all additional source scripts. Files need to be in directory ALPHABETICAL order if refrenced in a later object source file.
script_dir = File.join(ROOT, "AdditionalClasses")
if FileTest.directory?(script_dir)
  # map to hash parrent directory
  files = [script_dir].map do |path|
    if File.directory?(path)
      Dir[File.join(path, '**', '*.rb')] # grab EVERY .rb file in provided directory.
    else # dir to file
      path
    end
  end.flatten
  # require all located source file_dirs
  files.each do |source_file|
    begin
      require(source_file)
    rescue => error # catch syntax errors on a file basis
      temp = source_file.split('/').last
      puts("FO Error: loading dir (#{temp})\n#{error}")
    end
  end
end


#=====================================================================================================================================================
# Gosu display window for the game.
#=====================================================================================================================================================
class Program < Gosu::Window
  include QuickControls # takes care of all the button mapping and junk...
  #---------------------------------------------------------------------------------------------------------
  def initialize
    super(RESOLUTION[0], RESOLUTION[1], {:update_interval => UP_MS_DRAW, :fullscreen => ISFULLSCREEN})
    $program = self # global pointer to window creation object
    controls_init   # prep the input controls scheme manager
    @map_objects = [] # container for map related objects.
    # create the 3D camera viewpoint manager
    @camera_vantage = Camera3D_Object.new({:x => CAMERASTART[0], :y => CAMERASTART[1], :z => CAMERASTART[2]})
    #---------------------------------------------------------
    # create some new openGL_objects on the screen
    #@map_objects << Object2D.new(:texture => "cardboard") # 2D object, a texture basically...
    @map_objects << Object3D.new(:filename => "CardBoardBox", :texture => "cardboard")  # 3D object
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Return the current camera used to generate the 3D openGL perspective.
  #---------------------------------------------------------------------------------------------------------
  def camera3d_rotate_view(angle)
    return @camera_vantage.rotate_view_draw(angle)
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Called when a key is depressed. ID can be an integer or an array of integers that reference input symbols.
  #---------------------------------------------------------------------------------------------------------
  def button_down(id)
    super(id)
    unless @buttons_down.include?(id)
      @input_lag = INPUT_LAG
      @buttons_down << id
    end
    return unless PRINT_INPUT_KEY
    #print("Buttons currently held down: #{@buttons_down} T:#{@triggered}\n")
    print("Window button pressed: (#{id}) which is (#{self.get_input_symbol(id).to_s})\n")
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Called when a button was held but was released. ID can be an integer or an array of integers that 
  #D: reference input symbols.
  #---------------------------------------------------------------------------------------------------------
  def button_up(id)
    super(id)
    @buttons_up << id unless @buttons_up.include?(id)
  end
  #---------------------------------------------------------------------------------------------------------
  def update_input_controls
    # exit when holding esc key.
    if self.holding?(:cancel_action)
      self.close!
      return
    end
  end
  #---------------------------------------------------------------------------------------------------------
  def update
    super # empty caller
    input_update # updates the backend control scheme manager
    update_input_controls
    @camera_vantage.update # update the camera
    # update world 3d objects:
    @map_objects.each do |object3d|
      object3d.update unless object3d.nil?
    end
  end
  #---------------------------------------------------------------------------------------------------------
  def draw
    # you can perform Gosu.draw functions out side of ' gl ' blocks.
    #---------------------------------------------------------
    # !DO NOT MIX GOSU DRAW AND OPENGL DRAW CALLS!
    gl do
      # whiping screen is not the fastest way, should be internally manged better...
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glclear
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer
      glLoadIdentity()
      #---------------------------------------------------------
      # Camera object class internally manages viewing math.
      @camera_vantage.gl_view # you * ALWAYS * view before you draw.
      # draw the rest of the 3D objects:
      open_glDraw
    end
    # !DO NOT MIX GOSU DRAW AND OPENGL DRAW CALLS!
    #---------------------------------------------------------
    # Do not use gosu.draw while inside a gl operation function call! use them before or after blocks.
    @camera_vantage.draw # perhaps a HUD location?
    # objects draw to the " HUD area " as well? independent Gosu call back functions for the objects.
    @map_objects.each do |object3d|
      object3d.draw unless object3d.nil?
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Draw all the screen obects onto fresh screen, this can only be called from within a ' gl do ' block
  #D: or it will break. 
  #---------------------------------------------------------------------------------------------------------
  def open_glDraw
    @map_objects.each do |object3d|
      object3d.gl_draw unless object3d.nil?
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Called when the window in the OS is closed threw the system interfaces.
  #D: https://www.rubydoc.info/github/gosu/gosu/Gosu%2FWindow:close 
  #---------------------------------------------------------------------------------------------------------
  def close
    super
    @camera_vantage.destroy
    @map_objects.each do |object3d|
      object3d.destroy unless object3d.nil?
    end
    self.close!
  end
end

#=====================================================================================================================================================
Program.new.show # call and draw loop the Gosu::Window class object.
puts("Shutting down...")

