
#=====================================================================================================================================================
class Camera3D_Object < Basic3D_Object # @x, @y, @z are managed from a super class.
  attr_accessor :fov, :near, :far, :ratio, :tx, :ty, :tz, :vert_orintation
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
    @angle  = 0    # Which rotation on @vert_orintation is the camera looking?
    set_ratio # aspec ratio of view. ' screen size '
    #---------------------------------------------------------
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/Font
    @hud_font = Gosu::Font.new(22)
    @string = "" # container for HUD information
    #---------------------------------------------------------
    @time_between_debug_prints = 0
  end
  #---------------------------------------------------------------------------------------------------------
  def update_controls
    #--------------------------------------
    # Left Right X axis, Camera Position
    if    $program.holding?(:move_left)
      @x -= 1
    elsif $program.holding?(:move_right)
      @x += 1
    #--------------------------------------
    # Up Down Y axis, Camera Position
    elsif $program.holding?(:move_up)
      @y -= 1
    elsif $program.holding?(:move_down)
      @y += 1
    #--------------------------------------
    # Vertical Hight change, Camera Position
    elsif $program.holding?(:jump)
      @z -= 1
    elsif $program.holding?(:crouch)
      @z += 1
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
    update_controls
    unless DEBUG_PRINT_WAIT.nil?
      if @time_between_debug_prints <= 0
        @time_between_debug_prints = DEBUG_PRINT_WAIT
        puts("3D Camera: [#{@x},#{@y},#{@z}] - [#{@tx},#{@ty},#{@tz}]\n\tFov: #{@fov} View: #{@near} -> #{@far}")
      else
        @time_between_debug_prints -= 1
      end
    end
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called from $program Gosu::Window inside the draw method que. This is called after the interjection of gl_draw function.
  #D: At this location you can contruct a HUD for the viewing 3D environment.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def draw
    unless DEBUG_PRINT_WAIT.nil?
      @string = "3D Camera: [#{@x},#{@y},#{@z}] - [#{@tx},#{@ty},#{@tz}]\n\tFov: #{@fov} View: #{@near} -> #{@far}"
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

