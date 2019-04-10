#!/usr/bin/env ruby
#=====================================================================================================================================================
# Additional tutorials and usefull information.
#   https://github.com/vaiorabbit/ruby-opengl
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
# Load all additional source scripts.

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
# Global configuration settings.
#=====================================================================================================================================================
module Konfigure
  #---------------------------------------------------------------------------------------------------------
  UP_MS_DRAW  = 15    # 60 FPS = 16.6666 : 50 FPS = 20.0 : 40 FPS = 25.222
  #---------------------------------------------------------------------------------------------------------
  PRINT_INPUT_KEY = false # extra debug info on the input scheme manager.
  #---------------------------------------------------------------------------------------------------------
  # Defualt control scheme settings.
  DEFAULT_CONTROLS = { 
    #--------------------------------------
    # In game menu navigation
    #--------------------------------------
    :menu_up          => [:up   , :gp_up],
    :menu_down        => [:down , :gp_down],
    :menu_left        => [:left , :gp_left],
    :menu_right       => [:right, :gp_right],
    :menu_scroll_up   => [:gp_rbump, :mouse_wu],
    :menu_scroll_down => [:gp_lbump, :mouse_wd],
    :menu_action      => [:l_clk, :gp_0, :space, :return],
    #--------------------------------------
    # Player controls
    #--------------------------------------
    :move_up      => [:up   , :let_w, :gp_up],
    :move_down    => [:down , :let_s, :gp_down],
    :move_left    => [:left , :let_a, :gp_left],
    :move_right   => [:right, :let_d, :gp_right],
    :move_crouch  => [:lcrtl],
    :move_jump    => [:space],
    #--------------------------------------
    # Standards
    #--------------------------------------
    :action_key       => [:let_f, :gp_1],
    :mouse_lclick     => [:l_clk],
    :mouse_rclick     => [:r_clk],
    :cancel_action    => [:esc, :gp_cl],
    :debug_action_one => [:rctrl],
    :debug_action_two => [:return],
    #--------------------------------------
    # can not be used in above mapping, use both shifts individually.
    :shift => [:lshift, :rshift] # this is for keyboard character input modes only.
   }
  #---------------------------------------------------------------------------------------------------------
end

#=====================================================================================================================================================
# Gosu display window for the game.
#=====================================================================================================================================================
class Program < Gosu::Window
  include Konfigure
  include QuickControls # takes care of all the button mapping and junk...
  #---------------------------------------------------------------------------------------------------------
	def initialize
    super(800, 600, {:update_interval => UP_MS_DRAW, :fullscreen => false})
    $program = self # global pointer to window creation object
    controls_init   # prep the input controls scheme manager
    
    # create the 3D camera viewpoint manager
    @camera_vantage = Camera3D_Object.new({:x => 600, :y => 60, :z => 0})
    # create some new openGL_objects on the screen
    @openGL_object = Object3D.new()
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
    @openGL_object.update
	end
  #---------------------------------------------------------------------------------------------------------
  def draw
    # !DO NOT MIX GOSU DRAW AND OPENGL DRAW CALLS!
    gl do
      # whiping screen is not the fastest way, should be internally manged better...
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) # clear the screen and the depth buffer
      @camera_vantage.gl_view # Camera object class internally manages viewing math.
      # draw the rest of the 3D objects:
      open_glDraw 
    end
    # !DO NOT MIX GOSU DRAW AND OPENGL DRAW CALLS!
    #---------------------------------------------------------
    # Do not use gosu.draw while inside a gl operation function call! use them before or after blocks.
    @camera_vantage.draw # perhaps a HUD location?
    # objects draw to the " HUD area " as well? independent Gosu call back functions for the objects.
    @openGL_object.draw
  end
  #---------------------------------------------------------------------------------------------------------
  def open_glDraw
    # draw all the screen obects onto fresh screen.
    @openGL_object.gl_draw
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Called when the window in the OS is closed threw the system interfaces.
  #D: https://www.rubydoc.info/github/gosu/gosu/Gosu%2FWindow:close 
  #---------------------------------------------------------------------------------------------------------
  def close
    super
    @camera_vantage.destroy
    @openGL_object.destroy
    self.close!
  end
end

#=====================================================================================================================================================
Program.new.show # call and draw loop the Gosu::Window class object.
puts("Shutting down...")

