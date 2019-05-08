#=====================================================================================================================================================
# Global configuration settings.
#=====================================================================================================================================================
module Konfigure
  #---------------------------------------------------------------------------------------------------------
  CAMERASTART = [78, 2, 0] #  X, Y, Z location of camera in 3D world on object initialize.
  # You can configure the camera inside of file: ' AdditionalClasses/Camera_3D.rb ' check for comments on
  # further details there in file.
  #---------------------------------------------------------------------------------------------------------
  RESOLUTION   = [800, 600] # Display Gosu::Window size.
  ISFULLSCREEN = false      # Draw in full screen mode?
  #---------------------------------------------------------------------------------------------------------
  UP_MS_DRAW  = 15    # 60 FPS = 16.6666 : 50 FPS = 20.0 : 40 FPS = 25.222
  #---------------------------------------------------------------------------------------------------------
  PRINT_INPUT_KEY       = false # Extra debug info on the input scheme manager.
  DISPLAY_HARDWARE_INFO = false # print hardware information to Terminal?
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
    # 2D controls
    :move_up      => [:up  , :let_w, :gp_up],
    :move_down    => [:down, :let_s, :gp_down],
    # 3D controls
    :turn_left      => [:let_a, :left],
    :turn_right     => [:let_d, :right],
    :move_forword   => [:let_w, :up],
    :move_backwards => [:let_s, :down],
    # common controls
    :move_left    => [:left , :let_a, :gp_left],
    :move_right   => [:right, :let_d, :gp_right],
    :move_crouch  => [:let_c],
    :move_jump    => [:space],
    #--------------------------------------
    # Standards
    #--------------------------------------
    :action_key       => [:let_f, :gp_1],
    :mouse_lclick     => [:l_clk],
    :mouse_rclick     => [:r_clk],
    :cancel_action    => [:esc, :gp_cl],
    # debug button maps
    :debug_action_one => [:rctrl],
    :debug_action_two => [:return],
    #--------------------------------------
    # can not be used in above mapping, use both shifts individually.
    # these are for keyboard character input modes only.
    :shift => [:lshift, :rshift], 
    :ctrl  => [:lctrl, :rctrl],
    :alt   => [:lalt, :ralt]
   }
  #---------------------------------------------------------------------------------------------------------
end