
#=====================================================================================================================================================
class Camera3D_Object < Basic3D_Object # @x, @y, @z are managed from a super class.
  attr_accessor :fov, :near, :far, :ratio, :tx, :ty, :tz, :vert_orintation, :speed, :axial
  DEBUG_PRINT_WAIT = 20 # time between terminal information dumps, set nil to disable print out.
  DEBUG_SPIN = false # spin the camera in place to assist with viewing tests.
  #---------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    # set camera 3D world location
    super(options)
    #---------------------------------------------------------
    # target location in 3D world for the camera to look at.
    @tx = options[:tx] || 0.0
    @ty = options[:ty] || 0.0
    @tz = options[:tz] || 0.0
    #---------------------------------------------------------
    # which way is up?
    @vert_orintation = [1.0, 1.0, 1.0] # [X axis scale, Y axis scale, Z axis scale]
    #---------------------------------------------------------
    # Defualt camera display settings:
    @fov    = 45     # How wide can you view?
    @near   = 1.0    # How close can you see?
    @far    = 1000.0 # How far can you see?
    @speed  = 0.1    # Scale Speed to move at.
    @axial  = 0.1    # Scale Speed to turn at.
    set_ratio # aspec ratio of view. ' screen size ' uses Gosu::Window object.
    #---------------------------------------------------------
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/Font
    @hud_font = Gosu::Font.new(22)
    @string = "" # container for HUD information
    #---------------------------------------------------------
    @time_between_debug_prints = 0
  end
  #---------------------------------------------------------------------------------------------------------
  #D: How to spin in place and move relitive to direction facing.
  #---------------------------------------------------------------------------------------------------------
  def turning_move_style
    # spin
    @angle[0] -= @axial if $program.holding?(:turn_left)
    @angle[0] += @axial if $program.holding?(:turn_right)
    # momentum
    if $program.holding?(:move_backward)
      @x += @speed * Math::cos(@angle[0] * Math::PI / 180.0)
      @z += @speed * Math::sin(@angle[0] * Math::PI / 180.0)
    elsif $program.holding?(:move_forword)
      @x -= @speed * Math::cos(@angle[0] * Math::PI / 180.0)
      @z -= @speed * Math::sin(@angle[0] * Math::PI / 180.0)
    end
    # camera position updates
    @tx = @x - Math::cos(@angle[0] * Math::PI / 180.0)
    @ty = @y 
    @tz = @z - Math::sin(@angle[0] * Math::PI / 180.0) 
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Refer to image: ' Media/Screen_Shots/origin_explained.png '
  #---------------------------------------------------------------------------------------------------------
  def input_update_movement_controls
    #--------------------------------------
    # Left Right X axis, Camera Position
    if    $program.holding?(:move_left)
      @z -= @speed
    elsif $program.holding?(:move_right)
      @z += @speed
    #--------------------------------------
    # Up Down Y axis, Camera Position
    elsif $program.holding?(:move_up)
      @x -= @speed
    elsif $program.holding?(:move_down)
      @x += @speed
    #--------------------------------------
    # Vertical Hight change, Camera Position
    # more of a 'turn' then a straif type movment...
    elsif $program.holding?(:move_jump)
      @y -= @speed
    elsif $program.holding?(:move_crouch)
      @y += @speed
    #--------------------------------------
    end
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Viewing aspect ratio setting.
  #---------------------------------------------------------------------------------------------------------
  def set_ratio
    @ratio = $program.width.to_f / $program.height
  end
  #---------------------------------------------------------------------------------------------------------
  def update
    input_update_movement_controls
    # debug information:
    unless DEBUG_PRINT_WAIT.nil?
      if @time_between_debug_prints <= 0
        @time_between_debug_prints = DEBUG_PRINT_WAIT
        #puts(get_debug_string)
      else
        @time_between_debug_prints -= 1
      end
    end
    # rotate all 3D drawing after this call on camera viewing axis angle. Think world view angle.
    @angle[0] += 1.0 if DEBUG_SPIN
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: String used to convey usefull information to an area where the user can see it.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def get_debug_string
    s =  "3D Camera: [ #{@x.round(2)}, #{@y.round(2)}, #{@z.round(2)} ]\n"
    s += "  T[ #{@tx.round(2)}, #{@ty.round(2)}, #{@tz.round(2)} ]\n"
    s += "Fov: #{@fov.round(2)} View: #{@near.round(2)} -> #{@far.round(2)}\n\t"
    s += "Gosu::Window FPS (#{Gosu.fps})"
    return s
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called from $program Gosu::Window inside the draw method que. This is called after the interjection of gl_draw function.
  #D: At this location you can contruct a HUD for the viewing 3D environment.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def draw
    unless DEBUG_PRINT_WAIT.nil?
      @string = get_debug_string
    end
    @hud_font.draw_text(@string, 16, 16, 100, 1, 1, 0xff_ffffff, :default)
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Below POV is established and used to create the rendering of objects threw OpenGL.
  #---------------------------------------------------------------------------------------------------------
  def gl_view
    #---------------------------------------------------------
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glenable
    glEnable(GL_TEXTURE_2D) # enables two-dimensional texturing to perform
    #---------------------------------------------------------
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glmatrixmode
    glMatrixMode(GL_PROJECTION)
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glloadidentity
    glLoadIdentity  # * HAS TOO * be loaded in order after glMatrixMode setting...
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/gluperspective
    gluPerspective(@fov, @ratio, @near, @far)
    #---------------------------------------------------------
    # Camera placement and viewing arangements:
    # The modelview matrix is where camera object information is stored.
    glMatrixMode(GL_MODELVIEW); glLoadIdentity
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glulookat
    gluLookAt(@x,@y,@z,    # Camera Location          // eye
              @tx,@ty,@tz, # Viewing Target Location  // direction
      # Vector Direction of Movement.                 // up
      @vert_orintation[0], @vert_orintation[1], @vert_orintation[2]
    ) # Defining the Viewing perspective is done in this block.
    #---------------------------------------------------------
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glrotatef
    # glRotatef(angle, X axis scale, Y axis scale, Z axis scale)
    glRotatef(@angle[0], @vert_orintation[0], @vert_orintation[1], @vert_orintation[2])
  end
  #---------------------------------------------------------------------------------------------------------
  def destroy

  end
end

