#=====================================================================================================================================================
# This file was sourced from the opengl-bindings gem:
#   https://github.com/vaiorabbit/ruby-opengl/blob/master/sample/util/WavefrontOBJ.rb
# But some modifications have been made to provide some additional details.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# 3D software programs:
#   Autodesk 3ds Max Software   https://www.autodesk.com/products/3ds-max/overview
#           Maya                https://www.autodesk.com/products/maya/overview
#
# Free software:
#      Blender                https://www.blender.org/
#      Wings 3D               http://www.wings3d.com/
#
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Additional Notes on the .obj file format.
#   https://en.wikipedia.org/wiki/Wavefront_.obj_file#Vertex_Texture_Coordinate_Indices
#   https://en.wikibooks.org/wiki/OpenGL_Programming/Modern_OpenGL_Tutorial_Load_OBJ
#=====================================================================================================================================================
module WavefrontOBJ
  #=====================================================================================================================================================
  class Face
    attr_accessor :vertex_count # must be >= 3
    attr_accessor :vtx_index, :nrm_index, :tex_index
    #---------------------------------------------------------------------------------------------------------
    def initialize( vtx_count=3 )
      @vertex_count = vtx_count
      @vtx_index = Array.new( @vertex_count, -1 )
      @nrm_index = Array.new( @vertex_count, -1 )
      @tex_index = Array.new( @vertex_count, -1 )
    end
  end
  #=====================================================================================================================================================
  class Group
    attr_accessor :name, :face_index, :mtl_name, :displaylist
    attr_accessor :faces
    #---------------------------------------------------------------------------------------------------------
    def initialize( name="" )
      @name         = name
      @face_index   = Array.new
      @mtl_name     = nil
      @displaylist  = nil
      @faces        = Array.new # Face
    end
    #---------------------------------------------------------------------------------------------------------
    #D: Return a cached rendering of the object loaded for later drawing usage.
    #---------------------------------------------------------------------------------------------------------
    def gl_draw_list( model )
      @face_index.each do |fidx|
        # https://docs.microsoft.com/en-us/windows/desktop/opengl/glbegin
        #glBegin( GL_TRIANGLES )
        #glBegin( GL_QUADS )
        glBegin( GL_POLYGON )
          face = @faces[fidx]
          for i in 0...face.vertex_count do
            vi = face.vtx_index[i]
            ni = face.nrm_index[0] != -1 ? face.nrm_index[i] : nil
            ti = face.tex_index[0] != -1 ? face.tex_index[i] : nil

            glNormal3f( model.normal[ni][0], model.normal[ni][1], model.normal[ni][2] ) if ni
            glTexCoord2f( model.texcoord[ti][0], model.texcoord[ti][1] ) if ti
            glVertex3f( model.vertex[vi][0], model.vertex[vi][1], model.vertex[vi][2] )
          end
        glEnd()
      end
    end
  end
  #=====================================================================================================================================================
  class Model
    attr_reader :vertex, :normal, :texcoord, :smooth_shading, :material_lib
    attr_reader :object_name, :groups, :objects
    #---------------------------------------------------------------------------------------------------------
    def initialize(options = {})
      @verbose = options[:verbose] || false
      @object_name = "Defualt" # sat by loaded file name.

      @vertex    = Array.new
      @normal    = Array.new
      @texcoord  = Array.new
      @groups    = Hash.new   # face Groups

      @smooth_shading    = false
      @material_lib      = ""
      @current_materials = []
      @objects = []
    end
    #---------------------------------------------------------------------------------------------------------
    #D: return the objects total face count.
    #---------------------------------------------------------------------------------------------------------
    def get_face_count
      count = 0
      @groups.each_value do |grp|
        count += grp.faces.size
      end
      return count
    end
    #---------------------------------------------------------------------------------------------------------
    #D: Called from with in a ' gl do ' block after the object was properly loaded.
    #---------------------------------------------------------------------------------------------------------
    def render
      @groups.each_value do |grp|
        #print("#{grp.name} ")
        glCallList( grp.displaylist ) # call precahed operation to save gpu/cpu
      end
    end
    #---------------------------------------------------------------------------------------------------------
    #D: Read a .obj file and turn the lines into data points to create the object.
    #---------------------------------------------------------------------------------------------------------
    def parse( wofilename )
      wo_lines = IO.readlines( wofilename )
      @current_group = get_group( "default" )
      @current_material_name = "default"
      puts("+Loading .obj file:\n  \"#{wofilename.sub(ROOT, '')}\"") if @verbose
      # parse file context
      wo_lines.each do |line|
        tokens = line.split
        process_line(tokens[0], tokens[1..tokens.length-1])
      end
      @object_name = wofilename.split('/').last
      @object_name.sub!(".obj", '')
      puts("+Object name is \"#{@object_name}\" with (#{@objects.size}) Internal Objects.") if @verbose
      if get_group("default").faces.empty?
        @groups.delete("default")
      end
      @current_group = nil
      @current_material_name = nil
    end # parse
    #---------------------------------------------------------------------------------------------------------
    #D: Record the draw action for faster refrence in later gl_draws for the object.
    #---------------------------------------------------------------------------------------------------------
    def setup
      puts("+Constructing a total of (#{@groups.keys.size}) Groups:") if @verbose
      @groups.each_value do |grp|
        grp.displaylist = glGenLists( 1 )
        glNewList(grp.displaylist, GL_COMPILE )
        puts(" * \"#{grp.name}\" : Faces(#{grp.faces.size}) openGL draw list cached.") if @verbose
        grp.gl_draw_list(self) # create precahced draw operation
        glEndList()
      end
      puts("+Total Count of Faces: [ #{self.get_face_count} ]") if @verbose
      # display materials information
      puts("+Material Lib: \"#{material_lib}\" with (#{@current_materials.size}) Name Refrences.")  if @verbose
    end
    #---------------------------------------------------------------------------------------------------------
    #D: Returns Group object (or creates new Group when there's no matching group found)
    #---------------------------------------------------------------------------------------------------------
    def get_group( name )
      if ( !@groups.has_key?( name ) )
        @groups[name] = Group.new( name )
      end
      return @groups[name]
    end
    private :get_group
    #---------------------------------------------------------------------------------------------------------
    #D: Read each line of an object file exported with 3d party software for loading into OpenGL draw methods.
    #D: https://en.wikipedia.org/wiki/Wavefront_.obj_file
    #---------------------------------------------------------------------------------------------------------
    def process_line( key, values )
      case key
      #---------------------------------------------------------
      # List of geometric vertices, with (x, y, z [,w]) coordinates, 
      # w is optional and defaults to 1.0.
      when "v"
        values.collect! { |v| v.to_f }
        @vertex.push( values )
      #---------------------------------------------------------
      # List of vertex normals in (x,y,z) form; normals might not be unit vectors.
      # https://en.wikipedia.org/wiki/Normal_(geometry)
      when "vn"
        values.collect! { |v| v.to_f }
        @normal.push( values )
      #---------------------------------------------------------
      # List of texture coordinates, in (u, [v ,w]) coordinates, these 
      # will vary between 0 and 1, v and w are optional and default to 0.
      when "vt"
        values.collect! { |v| v.to_f }
        @texcoord.push( values[0..1] ) # u and v
      #---------------------------------------------------------
      # Named objects and polygon groups.
      when "o"
        @objects << values.first
      #---------------------------------------------------------
      # Polygon group names.
      when "g", "group"
        if values.length == 0
          # p "anonymous group detected. treat as \"default\"."
          @current_group = get_group( "default" )
        else
          # Only the first group is adopted even if there are multiple group names on the line.
          @current_group = get_group( values[0] )
        end
        @current_group.mtl_name = @current_material_name
      #---------------------------------------------------------
      # Smooth shading across polygons?
      when "s"
        setting = values.first # convert into boolean
        @smooth_shading = setting.include?('on') or setting.include?('true')
      #---------------------------------------------------------
      # Polygonal face element
      when "f"
        vertex_count = values.length
        case values[0]
        when /\d+\/\d+\/\d+/ # v/vt/vn
          face = Face.new( vertex_count )
          values.each_with_index do |value, i|
            v, vt, vn = value.split( '/' )
            face.vtx_index[i] = v.to_i  - 1
            face.tex_index[i] = vt.to_i - 1
            face.nrm_index[i] = vn.to_i - 1
          end
        #       --------------------------------------
        when /\d+\/\/\d+/ # v//vn
          face = Face.new( vertex_count )
          values.each_with_index do |value, i|
            v, vn = value.split( '//' )
            face.vtx_index[i] = v.to_i  - 1
            face.nrm_index[i] = vn.to_i - 1
          end
        #       --------------------------------------
        when /\d+\/\d+/ # v/vt
          face = Face.new( vertex_count )
          values.each_with_index do |value, i|
            v, vt = value.split( '/' )
            face.vtx_index[i] = v.to_i  - 1
            face.tex_index[i] = vt.to_i - 1
          end
        #       --------------------------------------
        when /\d+/ # v
          face = Face.new( vertex_count )
          values.each_with_index do |value, i|
            face.vtx_index[i] = value.to_i - 1
          end
        #       --------------------------------------
        else
          p "unknown face format detected."
        end
        @current_group.faces.push( face )
        @current_group.face_index.push( @current_group.faces.length - 1 )
      #---------------------------------------------------------
      when /^\#+/, nil
        #puts "comment or empty line."
      #---------------------------------------------------------
      # The .mtl file may contain one or more named material definitions. 
      when "mtllib"
        # https://en.wikipedia.org/wiki/Materials_system
        # https://en.wikipedia.org/wiki/Wavefront_.obj_file#Material_template_library
        @material_lib =  MaterialLibrary.new(values.first)
      #---------------------------------------------------------
      # The material name matches a named material definition in an external .mtl file.
      when "usemtl"
        @current_materials << values.first
      #---------------------------------------------------------
      else
        puts "  -Unsupported .obj token #{key} given. Ignored."
      end
    end # process_line
    private :process_line
  end
#=====================================================================================================================================================
end # model WavefrontOBJ