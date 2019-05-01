#=====================================================================================================================================================
# !!!   Basic3D_Object.rb  |  Bases for what a 3D object will commonally need for refrence vairables.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Basic3D_Object
  attr_accessor :x, :y, :z, :scale, :angle, :verbose
  attr_reader :destoryed
  #---------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    options = {} if options.nil?
    @x = options[:x] || 0.0
    @y = options[:y] || 0.0
    @z = options[:z] || 0.0
    # Scale to stretch the texture to.
    @scale = options[:scale] || 1.0 
    # spit out addional information to terminal when running.
    @verbose = options[:verbose] || false 
    @destoryed = false
    #---------------------------------------------------------
    reset_rotation_axis
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Perform common actions, angular object rotation perhaps?
  #---------------------------------------------------------------------------------------------------------
  def update
    return if @destoryed
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
    axis_list = axis.scan(/\w/) # multiple defined rotation axis? 'XY' or 'Zxy' type stuff.. or just 'z'
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
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called when its time to release the object to GC.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def destroy
    @destoryed = true
  end
end 