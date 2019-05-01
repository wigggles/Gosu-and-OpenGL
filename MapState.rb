#=====================================================================================================================================================
# !!!   map.rb  |  Container object that keeps track of all map related things.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Map
  @@camera_vantage = nil
  #---------------------------------------------------------------------------------------------------------
  #D:  Create the Klass object.
  #---------------------------------------------------------------------------------------------------------
  def initialize(**options)
    create_background()
    # store the options data for later refrence.
    @map_file = options[:level] || ""
    @map_objects = [] # container for map related objects.
    # create the 3D camera viewpoint manager
    @@camera_vantage = Camera3D_Object.new({:x => CAMERASTART[0], :y => CAMERASTART[1], :z => CAMERASTART[2]})
    #---------------------------------------------------------
    # create some new openGL_objects on the screen
    # 2D object, a texture basically...
    #@map_objects << Object2D.new(:texture => "cardboard", :x => 0.0, :y => 0.0)
    # 3D object, can apply a texture to a .obj mesh file.
    @map_objects << Object3D.new(:filename => "abstract", :texture => "cardboard")
    #
    #@map_objects << Object3D.new({ :filename => "test_cube", :verbose => true })
    @map_objects << Object3D.new({ :filename => "car", :verbose => true, :debug_draw => false })
    #---------------------------------------------------------
    # play with some rotation settings...
    @map_objects[0].set_axis_rotation({:speed => 0.5, :axis => 'XZ', :force => 1.0})
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Prep the background/foreground drawn objects.
  #---------------------------------------------------------------------------------------------------------
  def create_background
    # OpenGL sometimes uses colors in float values, this converts a hex into such color arrays.
    @bg_c = 0xFF_00ff00   # starts as a hex value, gets converted for OpenGL usage.
    # convert background color into color float:
    # [red, green, blue, alpha] = 0xalpha_redgreenblue
    colors = @bg_c.to_s(16)      # turn int into hex string
    colors = colors.scan(/.{2}/) # split hex string by color segments
    i = 0 # turn the provided hex color into an int value array
    @bg_c = [] # convert color value variable into storage object for ranges.
    colors.each do |color|
      # ranges 0.0 <-> 1.0
      if i > 0 # is red green or blue value
        color_range = color.to_i(16) / 255.to_f
        @bg_c.push(color_range)
      end
      i += 1
    end
    # add alpha to end: [1.0, 1.0, 1.0, 0.0]  ==  0x00_ffffff
    @bg_c.push(colors.first.to_i(16) / 255.to_f)
  end
  #---------------------------------------------------------------------------------------------------------
  #D: 
  #---------------------------------------------------------------------------------------------------------
  def update
    @@camera_vantage.update # update the camera
    # update world 3d objects:
    @map_objects.each do |object3d|
      object3d.update unless object3d.nil?
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: 
  #---------------------------------------------------------------------------------------------------------
  def draw
    @@camera_vantage.draw # perhaps a HUD location?
    # objects draw to the " HUD area " as well? independent Gosu call back functions for the objects.
    @map_objects.each do |object3d|
      object3d.draw unless object3d.nil?
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: 
  #---------------------------------------------------------------------------------------------------------
  def gl_draw
    # background in Gl render:
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glclearcolor
    # [ red, green, blue, alpha ] 0.0 <-> 1.0
    glClearColor(@bg_c[0], @bg_c[1], @bg_c[2], @bg_c[3])
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    # Camera object class internally manages viewing math.
    @@camera_vantage.gl_view
    # Draw the rest of the map objects.
    unless @map_objects.empty?
      @map_objects.each do |object3d|
        object3d.gl_draw unless object3d.nil?
      end
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: 
  #---------------------------------------------------------------------------------------------------------
  def camera_vantage
    return @@camera_vantage
  end
  #---------------------------------------------------------------------------------------------------------
  #D: 
  #---------------------------------------------------------------------------------------------------------
  def destroy
    @@camera_vantage.destroy
    @map_objects.each do |object3d|
      object3d.destroy unless object3d.nil?
    end
  end
end

