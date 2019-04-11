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
    @filename    = options[:filename] || ""
    #---------------------------------------------------------
    @object_name = ''       # Is there an object name provided from .obj file or one set to this Ruby Object?
    @texture_resource = nil # A string or array that contains the name of textures used when drawing the .obj
    @v  = [] # vertexes
    @vt = [] # vertexes texture coordinate.
    @vn = [] # vertexes face normals, if provied in file.
    @vert_cache = []    # temp storage used when loading.
    @face_count = 0     # how many faces the object has.
    @useshaders = false # draw with shaders, is set by loading the .obj file.
    # debug printing of information, time between update posts for string creation.
    @time_between_debug_prints = 0
    @hud_font = Gosu::Font.new(22) # Gosu::Font container
    @string = "" # container for HUD information
    #---------------------------------------------------------
    # begin interprating the 3D object file.
    if VERBOSE
      puts("-" * 70)
      puts("Initializing new OpenGL 3D object...")
    end
    load_obj_file # try loading a source .obj file
    if VERBOSE
      puts("New 3D object created: ( #{@object_name} )")
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
  #D: take place. in OpenGL, you only draw at [0, 0, 0], no matter what...
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def gl_draw
    
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Debug tool to print out information about the object.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def get_debug_string
    string = "Object(#{@object_name}) F[#{@face_count}]\nVectors[#{@v.size},t#{@vt.size},n#{@vn.size}]"
    return string
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Load a .obj file into memory and use it to to build the OpenGL cache for drawing later.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def load_obj_file
    read_objfile # reads source file and preps working variables to build object data points.    
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Read each line of an object file exported with 3d party software for loading into OpenGL draw methods.
  #D: https://en.wikibooks.org/wiki/OpenGL_Programming/Modern_OpenGL_Tutorial_Load_OBJ
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def read_objfile
    # create temp vertex containers.
    v, vt, vn = Array.new, Array.new, Array.new
    face_verts = []
    #---------------------------------------------------------
    # check to make sure the file exists inside of the media folder.
    file_dir = File.join(ROOT, "Media/3dModels/#{@filename}.obj") rescue nil
    unless FileTest.exists?(file_dir)
      puts("3dObject Load Error: Could not find 3D object source file. ( #{@filename}.obj )")
      return nil
    end
    #---------------------------------------------------------
    # read each line from top to bottom inside the .obj text file.
    File.open(file_dir).readlines.each do |line|
      next if line.include?('#') # is a comment, just like // in C++, skip them in reading.
      #---------------------------------------------------------
      # 'o' object type if defined, name of object from software that exported.
      if line[0] == 'o' 
        @object_name = line.sub('o ', '').sub("\n", '')
      #---------------------------------------------------------
      # shaders setting?
      elsif line[0] == 's'
        @useshaders = line.include?('true')
      #---------------------------------------------------------
      # 'usemtl' is the file name of the texture to use.
      # 'mtllib' describe the look of the model. We won’t use this in this tutorial.
      elsif line.include?("usemtl ")
        @texture_resource = line.sub('usemtl ', '').sub("\n", '')
      #---------------------------------------------------------
      # 'vt' is the texture coordinate of one vertex. [ vt %d %d %d ]
      elsif line.include?("vt ")
        line.split(' ').each do |float_value|
          next if float_value.include?("vt")
          vt << float_value.to_f
        end
      #---------------------------------------------------------
      # 'vn' is the normal of one vertex. [ vn %d %d ]
      elsif line.include?("vn ")
        line.split(' ').each do |float_value|
          next if float_value.include?("vn")
          vn << float_value.to_f
        end
      #---------------------------------------------------------
      # 'v' is a vertex. [ v %d %d %d ]
      elsif line.include?("v ")
        line.split(' ').each do |float_value|
          next if float_value.include?("v")
          v << float_value.to_f
        end
      #---------------------------------------------------------
      # 'f' is a face. For triangle based shape exports that create the .obj file.
      # normalize the object faces by combining them with the vertexes?
      #   [ f %d//%d//%d %d//%d//%d %d//%d//%d ]
      # %d/%d/%d describes the first  vertex of the triangle.
      # %d/%d/%d describes the second vertex of the triangle.
      # %d/%d/%d describes the third  vertex of the triangle.
      elsif line[0] == 'f'
        puts("Faces: \" #{line.sub("\n", '')} \"") if VERBOSE
        line.split(' ').each do |face|
          next if face.include?("f")
          print(" face: #{face} [ ") if VERBOSE
          # index is file line order.
          face.split('//').each do |float_value|
            face_verts << float_value.to_f
            print("#{float_value} ") if VERBOSE
          end
          print("]\n") if VERBOSE
        end
        # keep count of the number of faces the objet uses.
        @face_count += 1
      end
    end
    #---------------------------------------------------------
    # normalize the viewing faces using the vertexes.
    @v.push(v[face_verts[0] - 1])   # first  vertex triangle.
    @v.push(v[face_verts[3] - 1])   # second vertex triangle.
    @v.push(v[face_verts[6] - 1])   # third  vertex triangle.
    
    @vt.push(vt[face_verts[1] - 1]) # first  vertex triangle.
    @vt.push(vt[face_verts[4] - 1]) # second vertex triangle.
    @vt.push(vt[face_verts[7] - 1]) # third  vertex triangle.
    
    @vn.push(vn[face_verts[2] - 1]) # first  vertex triangle.
    @vn.push(vn[face_verts[5] - 1]) # second vertex triangle.
    @vn.push(vn[face_verts[8] - 1]) # third  vertex triangle.
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called when its time to release the object to GC.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def destroy

  end
end
