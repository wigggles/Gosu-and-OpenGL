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
    @map_file = options[:level] || ""
    @map_objects = [] # container for map related objects.
    # create the 3D camera viewpoint manager
    @@camera_vantage = Camera3D_Object.new({:x => CAMERASTART[0], :y => CAMERASTART[1], :z => CAMERASTART[2]})
    #---------------------------------------------------------
    # create some new openGL_objects on the screen
    # 2D object, a texture basically...
    #@map_objects << Object2D.new(:texture => "cardboard", :x => 0.0, :y => 0.0)
    # 3D object, can apply a texture to a .obj mesh file.
    #@map_objects << Object3D.new(:filename => "abstract", :texture => "cardboard")
    #
    #@map_objects << Object3D.new({ :filename => "test_cube", :verbose => true })
    @map_objects << Object3D.new({ :filename => "car", :verbose => true })
    #---------------------------------------------------------
    # play with some rotation settings...
    @map_objects[0].set_axis_rotation({:speed => 0.5, :axis => 'XZ', :force => 1.0})
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

