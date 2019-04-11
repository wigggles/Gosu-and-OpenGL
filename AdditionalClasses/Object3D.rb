#=====================================================================================================================================================
# !!!   3dObject.rb  |  Basic OpenGL object displayed in 3D, can load .obj files from Blender or Wing3D.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Object3D < Basic3D_Object
  DEBUG_PRINT_WAIT = 20 # time between terminal information dumps, set nil to disable print out.
  VERBOSE = true # spit out addional information to terminal when running.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Creates Kernal class Object. (Klass)
  #D: http://www.opengl-tutorial.org/beginners-tutorials/tutorial-7-model-loading/#loading-the-obj
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    super(options)
    @obj_filename = options[:filename] || ""
    @texture_file = options[:texture]  || "" # eventually wil tie into the load module.
    @scale = 1.0 # scale to stretch the texture to.
    #---------------------------------------------------------
    @object_name = ''       # Is there an object name provided from .obj file or one set to this Ruby Object?
    @texture_resource = nil # A string or array that contains the name of textures used when drawing the .obj
    @v  = [] # vertexes
    @vt = [] # vertexes texture coordinate.
    @vn = [] # vertexes face normals, if provied in file.
    @vert_cache = []    # temp storage used when loading.
    @face_count = 0     # how many faces the object has.
    @useshaders = false # draw with shaders, is set by loading the .obj file.
    @object_model = nil # container that holds onto the 3d object.
    # debug printing of information, time between update posts for string creation.
    @time_between_debug_prints = 0
    @hud_font = Gosu::Font.new(22) # Gosu::Font container
    @string = "" # container for HUD information
    #---------------------------------------------------------
    # begin interprating the 3D object file.
    if VERBOSE
      puts("-" * 70)
      puts("Initializing new OpenGL 3D object... #{self}")
    end
    load_obj_file # try loading a source .obj file
    if VERBOSE
      puts("New 3D object created, group: ( #{@object_name} )")
      puts("-" * 70)
    end
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Usually called from a loop to push variable changes and automate function triggers.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def update
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
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def gl_draw
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/gltranslatef
    glTranslatef(0, 0, 0) # Moving function from the current gluPerspective by x,y,z change
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glrotatef
    glRotatef(0.0, 0.0, 1.0, 0.0) # Rotation function.
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/GLTexInfo
    glBindTexture(GL_TEXTURE_2D, @tex_info.tex_name)
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glscalef
    glScalef(@scale, @scale, @scale)
    #---------------------------------------------------------
    # call the cached draw recording for the model.
    @object_model.render
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Debug tool to print out information about the object.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def get_debug_string
    string = "Object(#{@obj_filename})\nfaces(#{@face_count}) texture:\n  \"#{@texture_file}\""
    return string
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Load a .obj file into memory and use it to to build the OpenGL cache for drawing later.
  #D: https://help.sansar.com/hc/en-us/articles/115002888226-3D-model-export-and-setup-tips-using-popular-3D-tools-
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def load_obj_file
    use_wavefrontOBJ_loader
    # save the @texture refrence as its refered to later and you dont want to loose the refrence object.
    @texture = Gosu::Image.new(File.join(ROOT, "Media/Textures/#{@texture_file}.png"), retro: true) rescue nil
    if @texture.nil?
      puts("Texture image file was not found for: #{@texture_file}")
      exit
    end
    puts("Using texture file: \"Media/Textures/#{@texture_file}.png\"")
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
    @object_model = WavefrontOBJ::Model.new # create new container
    @object_model.parse(file_dir)           # load file
    @object_model.setup                     # create draw recording array
    # confirm creaion, get some details about the object.
    #puts("#{@object_model.groups.first[0].to_s} #{@object_model.groups[@object_name].faces.size}")
    @object_name = @object_model.groups.first[0].to_s
    @face_count  = @object_model.groups[@object_name].faces.size
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called when its time to release the object to GC.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def destroy

  end
end
