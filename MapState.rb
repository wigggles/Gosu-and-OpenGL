#=====================================================================================================================================================
# !!!   map.rb  |  Container object that keeps track of all map related things.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Map
  @@camera_vantage = nil
  @@map_3D_polydata = nil
  attr_accessor :map_objects
  #---------------------------------------------------------------------------------------------------------
  #D:  Create the Klass object.
  #---------------------------------------------------------------------------------------------------------
  def initialize(**options)
    create_background()
    # store the options data for later refrence.
    @map_file = options[:level] || ""
    load_3D_mapfile() unless @map_file.length < 1
    @map_objects = [] # container for map related objects.
    # create the 3D camera viewpoint manager
    @@camera_vantage = Camera3D_Object.new({:x => CAMERASTART[0], :y => CAMERASTART[1], :z => CAMERASTART[2]})
    #---------------------------------------------------------
    # create some new openGL_objects on the screen
    # 2D object, a texture basically...
    #@map_objects << Object2D.new(:texture => "cardboard", :x => 0.0, :y => 0.0)
    #@map_objects.last.set_axis_rotation({:speed => 0.7, :axis => 'YZX', :force => 1.0})
    # 3D object, can apply a texture to a .obj mesh file.
    #    ------------------
    # This cube can be the starting of representation of space.
    #@map_objects << Object3D.new({ :filename => "test_cube", :verbose => false })
    #@map_objects.last.set_axis_rotation({:speed => 0.5, :axis => 'XZ', :force => 1.0})
    #    ------------------
    #@map_objects << Object3D.new({ :filename => "car", :texture => "car-hires", :verbose => false, :debug_draw => false })
    #@map_objects.last.set_axis_rotation({:speed => -0.8, :axis => 'YXZ', :force => 1.5})
    #    ------------------
    # Chair provided by: https://free3d.com/3d-model/chair-16205.html
    # Free personal use liciense, can not sell if you include this model. Check link.
    #@map_objects << Object3D.new({ :filename => "chair",:texture => "Tests/test_00", :verbose => false, :debug_draw => false })
    #@map_objects.last.set_axis_rotation({:speed => -0.8, :axis => 'YXZ', :force => 1.5})
    #    ------------------
    # the bellow object load fails, but reports the issue and cleans up.
    #@map_objects << Object3D.new(:filename => "abstract", :texture => "cardboard") 
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Load a 3D map, Sledge offers a wavefront .obj file save for the map for later loading.
  #---------------------------------------------------------------------------------------------------------
  def load_3D_mapfile()
    map_dir = "Media/Maps/#{@map_file}.obj"
    @@map_3D_polydata = Object3D.new({ 
      :filename   => map_dir, 
      :verbose    => true, 
      :debug_draw => true
    })
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
    run_cleaner = []
    i = -1
    @map_objects.each do |object3d|
      i += 1
      unless object3d.nil?
        if object3d.destroyed?
          run_cleaner << i # flag for removal
        else 
          object3d.update  # normal update
        end
      else # flag for removal because is nil index
        run_cleaner << i
      end
    end
    # update the 3D map
    unless @@map_3D_polydata.nil?
      @@map_3D_polydata.update
    end
    # run the cleaner agains the marked indexs
    unless run_cleaner.empty?
      run_cleaner.each do |remove_index|
        @map_objects.delete_at(remove_index)
      end
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: 
  #---------------------------------------------------------------------------------------------------------
  def draw
    @@camera_vantage.draw # perhaps a HUD location?
    # draw the 3D map 2d sprite aspects:
    @@map_3D_polydata.draw unless @@map_3D_polydata.nil?
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
    # Draw the 3D object map data:
    @@map_3D_polydata.gl_draw unless @@map_3D_polydata.nil?
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
    @@map_3D_polydata.destroy unless @@map_3D_polydata.nil?
    @map_objects.each do |object3d|
      object3d.destroy unless object3d.nil?
    end
  end
end

