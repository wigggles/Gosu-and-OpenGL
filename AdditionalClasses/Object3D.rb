#=====================================================================================================================================================
# !!!   3dObject.rb  |  Basic OpenGL object displayed in 3D, can load .obj files from Blender or Wing3D.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Don't want to make .obj files your self, check for free ones online...
#   https://www.hongkiat.com/blog/60-excellent-free-3d-model-websites/
#=====================================================================================================================================================
class Object3D < Basic3D_Object
  DEBUG_PRINT_WAIT = 20 # time between terminal information dumps, set nil to disable print out.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Creates Kernal class Object. (Klass)
  #D: http://www.opengl-tutorial.org/beginners-tutorials/tutorial-7-model-loading/#loading-the-obj
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    super(options)
    @obj_filename = options[:filename] || ""
    @texture_file = options[:texture]  || "" # eventually wil tie into the load module.
    #---------------------------------------------------------
    @object_name  = ''      # Is there an object name provided from .obj file or one set to this Ruby Object?
    @face_count   = 0       # how many faces the object has.
    @object_model = nil     # container that holds onto the wavefront 3d object data.
    @texture_resource = nil # A string or array that contains the name of textures used when drawing the .obj
    # debug printing of information, time between update posts for string creation.
    @time_between_debug_prints = 0
    @hud_font = Gosu::Font.new(22) # Gosu::Font container
    @string   = "" # container for HUD information
    #---------------------------------------------------------
    # begin interprating the 3D .obj file.
    if @verbose
      puts("-" * 70)
      puts("Initializing new OpenGL 3D object... #{self}")
    end
    load_obj_file # try loading a source .obj file
    if @verbose
      puts("New 3D object created from: ( #{@object_name}.obj )")
      puts("-" * 70)
    end
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Usually called from a loop to push variable changes and automate function triggers.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def update
    super
    #---------------------------------------------------------
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
  #D: Called from $program Gosu::Window inside the draw method que. This is called after the interjection of gl_draw function.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def draw
    unless DEBUG_PRINT_WAIT.nil?
      @string = get_debug_string
    end
    @hud_font.draw_text(@string, $program.width - 200, $program.height - 300, 100, 1, 1, 0xff_ffffff, :default)
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called from $program Gosu::Window inside draw, this happens before any Gosu::Font or Gosu::Image actions
  #D: take place. 
  #D: https://docs.microsoft.com/en-us/windows/desktop/opengl/glprioritizetextures
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def gl_draw
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glpushmatrix
    glPushMatrix # for the most part operations should keep to themselfs with location configuration.
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/gltranslatef
      glTranslatef(@x, @y, @z) # Moving function from the current gluPerspective by x,y,z change
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glrotatef
      # glRotatef(angle, X axis scale, Y axis scale, Z axis scale)
      glRotatef(@angle[0], @angle[1], @angle[2], @angle[3])
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glpushmatrix
      # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/GLTexInfo
      glBindTexture(GL_TEXTURE_2D, @tex_info.tex_name)
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glscalef
      glScalef(@scale, @scale, @scale)
      #---------------------------------------------------------
      # call the cached draw recording for the model.
      @object_model.render
      #---------------------------------------------------------
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glpopmatrix
    glPopMatrix
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Load a .obj file into memory and use it to to build the OpenGL cache for drawing later.
  #D: https://help.sansar.com/hc/en-us/articles/115002888226-3D-model-export-and-setup-tips-using-popular-3D-tools-
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def load_obj_file
    use_wavefrontOBJ_loader
    # save the @texture refrence as its refered to later and you dont want to loose the refrence object.
    file = "Media/Textures/#{@texture_file}.png"
    file_dir = File.join(ROOT, file)
    @texture = Gosu::Image.new(file_dir, retro: true) rescue nil
    if @texture.nil?
      puts("Texture image file was not found for: #{@texture_file}")
      exit
    end
    puts("Using local 3D object file texture setting:\n  \"#{file}\"")
    #--------------------------------------
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/Image#gl_tex_info-instance_method
    @tex_info = @texture.gl_tex_info # helper structure that contains image data
    # This vlaue is tied into the storage method of the Gosu::Image object and can not be changed.
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Turns out the gem for OpenGL drawing has some features tucked away in the samples.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def use_wavefrontOBJ_loader
    file_dir = File.join(ROOT, "Media/3dModels/#{@obj_filename}.obj") rescue nil
    unless FileTest.exists?(file_dir)
      puts("3dObject Load Error: Could not find 3D object source file. ( #{@obj_filename}.obj )")
      return nil
    end
    #---------------------------------------------------------
    # module that manages loading of 3d objects.
    options = {:verbose => @verbose}
    @object_model = WavefrontOBJ::Model.new(options)
    # seperated to allow for load steping for larger object groups...
    @object_model.parse(file_dir)           # load file
    @object_model.setup                     # create draw recording array
    # confirm creaion, get some details about the object.
    @object_name = @object_model.object_name
    @face_count  = @object_model.get_face_count
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called when its time to release the object to GC.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def destroy

  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Debug tool to print out information about the object.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def get_debug_string
    string = "Object(#{@obj_filename})\nfaces(#{@face_count}) texture:\n  \"#{@texture_file}\""
    return string
  end
end
