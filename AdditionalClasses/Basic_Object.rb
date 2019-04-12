#=====================================================================================================================================================
# !!!   Basic3D_Object.rb  |  Bases for what a 3D object will commonally need for refrence vairables.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Basic3D_Object
  attr_accessor :x, :y, :z, :scale, :angle
  #---------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    options = {} if options.nil?
    @x = options[:x] || 0.0
    @y = options[:y] || 0.0
    @z = options[:z] || 0.0
    # Scale to stretch the texture to.
    @scale = options[:scale] || 1.0  
    #---------------------------------------------------------
    reset_rotation_axis
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Perform common actions, angular object rotaiton perhaps?
  #---------------------------------------------------------------------------------------------------------
  def update
    # current plus speed
    @angle[0] += @angle.last
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Rotation function for the object space. Calling this resets the objects draw rotation.
  #---------------------------------------------------------------------------------------------------------
  def reset_rotation_axis
    # [angle, X axis scale, Y axis scale, Z axis scale, speed]
    @angle = [0.0, 0.0, 0.0, 0.0, 0.0] 
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Set the applied rotational force applied to the object. {:speed, :axis, :force}
  #---------------------------------------------------------------------------------------------------------
  def set_axis_rotation(options = {})
    speed = options[:speed] || 0.0
    axis  = options[:axis]  || 'x'
    force = options[:force] || 0.0
    #---------------------------------------------------------
    axis_list = axis.scan(/\w/)
    axis_list.each do |axis|
      case axis
      when 'x', 'X'
        @angle[1] = force
      when 'y', 'Y'
        @angle[2] = force
      when 'z', 'Z'
        @angle[3] = force
      else # assume error,
        puts("Un-known rotation axis (#{axis}) for basic object.")
        puts caller # back trace
        exit# shut down...
      end
    end
    #---------------------------------------------------------
    @angle << speed # last index is always speed.
  end
end 