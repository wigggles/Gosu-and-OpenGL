#=====================================================================================================================================================
# !!!   3dObject.rb  |  Basic OpenGL object displayed in 3D, can load .obj files from Blender or Wing3D.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Don't want to make .obj files your self, check for free ones online...
#   https://www.hongkiat.com/blog/60-excellent-free-3d-model-websites/
#
# Blender Tuts:
#   https://youtu.be/1q5QoyK9Rxk?t=56   - Materials Application
#   https://youtu.be/eiDrRa6JvQ0?t=773  - UV mapping
#=====================================================================================================================================================
class Object3D < Basic3D_Object
  TEXTURE_DEBUG = false
  DEBUG_PRINT_WAIT = 20 # time between terminal information dumps, set nil to disable print out.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Creates Kernal class Object. (Klass)
  #D: http://www.opengl-tutorial.org/beginners-tutorials/tutorial-7-model-loading/#loading-the-obj
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    super(options)
    @obj_filename = options[:filename] || ""
    @texture_file = options[:texture]  || @obj_filename # eventually will tie into the load module.
    @texture_debugging = TEXTURE_DEBUG || options[:debug_draw] # skip drawing texture, use defualt mat white.
    #---------------------------------------------------------
    @object_name  = ''      # Is there an object name provided from .obj file or one set to this Ruby Object?
    @face_count   = 0       # how many faces the object has.
    @object_model = nil     # container that holds onto the wavefront 3d object data.
    @texture_resource = nil # A string or array that contains the name of textures used when drawing the .obj
    # debug printing of information, time between update posts for string creation.
    @time_between_debug_prints = 0
    @hud_font = Gosu::Font.new(22) # Gosu::Font container
    @string   = "" # container for HUD information
    # try loading a source .obj file
    success = load_obj_file() rescue nil
    if success.nil?
      # there was an issue that was reported that resulted in a fail loading.
      puts("issue with object loading (#{@obj_filename})")
      puts("-" * 70)
      self.destroy # mark for map clean up/ removal
      return nil
    else
      if @verbose
        puts("-" * 70)
        puts("Initializing new OpenGL 3D object... #{self}")
      end
    end
    # speak if asked.
    if @verbose
      puts("New 3D object created from: \"#{@object_name}.obj\"")
      puts("-" * 70)
    end
    #@scale = 1.0 # scale the whole object.
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Usually called from a loop to push variable changes and automate function triggers.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def update
    return if @destoryed
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
    return if @destoryed
    return unless @verbose
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
    return if @destoryed # map will take care of the class object.
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
      # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/GLTexInfo
      if @texture.nil? || @texture_debugging
        # debug texture drawing: helps find things by painting them a color.
        # https://docs.microsoft.com/en-us/windows/desktop/opengl/gldisable
        glDisable(GL_TEXTURE_2D)
        # https://docs.microsoft.com/en-us/windows/desktop/opengl/glcolor3ub
        glColor3ub(255, 100, 100) # or a diffrent color if desired...
      else # normal drawing
        # https://docs.microsoft.com/en-us/windows/desktop/opengl/glpushmatrix
        glBindTexture(GL_TEXTURE_2D, @texture.tex_name)
      end
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glscalef
      # scales the whole object including texture mapping.
      glScalef(@scale, @scale, @scale)
      #---------------------------------------------------------
      # call the cached draw recording for the model.
      unless @object_model.nil?
        @object_model.render
      else
        puts("No model to draw for object: [ #{@obj_filename} ]")
        exit
      end
      #---------------------------------------------------------
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glpopmatrix
    glPopMatrix
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Load a .obj file into memory and use it to to build the OpenGL cache for drawing later.
  #D: https://help.sansar.com/hc/en-us/articles/115002888226-3D-model-export-and-setup-tips-using-popular-3D-tools-
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def load_obj_file
    if self.use_wavefrontOBJ_loader() == nil
      # there was an issue loading the object data, dont bother with the image file.
      return nil
    end
    # save the @texture refrence as its refered to later and you dont want to loose the refrence object.
    if @obj_filename != @texture_file
      file = "Media/Textures/#{@texture_file}.png"
    else # nest the object file, keeps the directory cleaner this way.
      file = "Media/3dModels/#{@texture_file}/#{@texture_file}.png"
    end
    file_dir = File.join(ROOT, file)
    image = Gosu::Image.new(file_dir, retro: true) rescue nil
    if image.nil?
      puts("Texture image file was not found for: #{file_dir}")
      unless TEXTURE_DEBUG
        exit
      else
        return true
      end
    end
    @texture = Yume::Texture.new(image)
    puts("Using local 3D object file texture setting:\n  \"#{file}\"")
    #--------------------------------------
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/Image#gl_tex_info-instance_method
    # @tex_info = @texture.gl_tex_info # helper structure that contains image data
    # not very reliably held to tho, needs a proper class object formater to load images as textures.
    return true # success
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Turns out the gem for OpenGL drawing has some features tucked away in the samples.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def use_wavefrontOBJ_loader
    # nest the object file, keeps the directory cleaner this way.
    @file_dir = File.join(ROOT, "Media/3dModels/#{@obj_filename}/#{@obj_filename}.obj") rescue nil
    unless FileTest.exists?(@file_dir)
      puts("Mesh Loader Error: Could not find 3D object (#{@obj_filename}) source file.\n  #{@file_dir}")
      #throw Error.new() 
      #exit
      return nil
    end
    #---------------------------------------------------------
    # module that manages loading of 3d objects.
    options = {:object_name => @obj_filename, :verbose => @verbose}
    @object_model = WavefrontOBJ::Model.new(options) rescue nil
    if @object_model.nil?
      puts("Failed to load model data for: (#{@obj_filename})")
      self.destroy # mark self for clean up from object container in map
      return nil
    end
    # seperated to allow for load steping for larger object groups...
    @object_model.setup() # create draw recording array
    # confirm creaion, get some details about the object.
    @object_name = @object_model.object_name
    @face_count  = @object_model.get_face_count
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called when its time to release the object to GC.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def destroy
    super
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Debug tool to print out information about the object.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def get_debug_string
    string = "Object(#{@obj_filename})\nfaces(#{@face_count}) texture:\n  \"#{@texture_file}\""
    return string
  end
end
