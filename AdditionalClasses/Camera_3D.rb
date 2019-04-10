
#=====================================================================================================================================================
class Camera3D_Object < Basic3D_Object # @x, @y, @z are managed from a super class.
  attr_accessor :fov, :near, :far, :ratio, :tx, :ty, :tz, :vert_orintation, :speed, :axial
  DEBUG_PRINT_WAIT = 20 # time between terminal information dumps, set nil to disable print out.
  DEBUG_SPIN = true # spin the camera in place to assist with viewing tests.
  #---------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    # set camera 3D world location
    super(options)
    #---------------------------------------------------------
    # target location in 3D world for the camera to look at.
    @tx = options[:tx] || 0
    @ty = options[:ty] || 0
    @tz = options[:tz] || 0
    #---------------------------------------------------------
    # which way is up?
    @vert_orintation = [0, 1, 0] # [X axis, Y axis, Z axis]
    #---------------------------------------------------------
    @fov    = 45   # How wide can you view?
    @near   = 1    # How close can you see?
    @far    = 1000 # How far can you see?
    @angle  = 0    # Which angle of rotation on @vert_orintation is the camera looking?
    @speed  = 3.0  # Speed to move at.
    @axial  = 1.0  # Speed to turn at.
    set_ratio # aspec ratio of view. ' screen size '
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
    @angle -= @axial if $program.holding?(:turn_left)
    @angle += @axial if $program.holding?(:turn_right)
    # momentum
    if $program.holding?(:move_backward)
      @x += @speed * Math::cos(@angle * Math::PI / 180.0)
      @z += @speed * Math::sin(@angle * Math::PI / 180.0)
    elsif $program.holding?(:move_forword)
      @x -= @speed * Math::cos(@angle * Math::PI / 180.0)
      @z -= @speed * Math::sin(@angle * Math::PI / 180.0)
    end
    # camera position updates
    @tx = @x - Math::cos(@angle * Math::PI / 180.0)
    @ty = @y 
    @tz = @z - Math::sin(@angle * Math::PI / 180.0) 
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
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: String used to convey usefull information to an area where the user can see it.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def get_debug_string
    s =  "3D Camera: [#{@x},#{@y},#{@z}] - [#{@tx},#{@ty},#{@tz}]\n\t"
    s += "Fov: #{@fov} View: #{@near} -> #{@far}\n\t"
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
    glEnable(GL_TEXTURE_2D) # enables two-dimensional texturing to perform
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity 
    gluPerspective(@fov, @ratio, @near, @far)
    #---------------------------------------------------------
    glMatrixMode(GL_MODELVIEW) # The modelview matrix is where camera object information is stored.
    glLoadIdentity # * HAS TOO * be loaded in order after glMatrixMode setting...
    # Camera placement and viewing arangements:
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glulookat
    gluLookAt(@x,@y,@z,    # Camera Location
              @tx,@ty,@tz, # Viewing Target Location
      # Vector Direction of Movement.
      @vert_orintation[0], @vert_orintation[1], @vert_orintation[2]
    ) # Defining the Viewing perspective is done in this block.
    #---------------------------------------------------------
    @angle += 1 if DEBUG_SPIN
    # rotate all 3D drawing after this call on viewing axis angle.
    glRotatef(@angle, @vert_orintation[0], @vert_orintation[1], @vert_orintation[2])
  end
  #---------------------------------------------------------------------------------------------------------
  def destroy

  end
end

