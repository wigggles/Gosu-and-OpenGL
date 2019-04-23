#=====================================================================================================================================================
# https://en.wikipedia.org/wiki/Materials_system
# https://learnopengl.com/Lighting/Materials
#=====================================================================================================================================================
class MaterialLibrary
  @@verbose = true
  @@material_files = nil
  #---------------------------------------------------------------------------------------------------------
  #D:  Create the Klass object.
  #---------------------------------------------------------------------------------------------------------
  def initialize(filename = "")
    @@material_files = {} if @@material_files.nil?
    @current_material = nil
    @filename = filename
    # gen new materials cache...
    if @@material_files[@filename].nil?
      parse_mtl_file
    end
    # return the cahced materials file
    return @@material_files[@filename]
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Empty the material cache.
  #---------------------------------------------------------------------------------------------------------
  def self.dump_all_materials
    @@material_files = nil
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Read each line of the materlail library file exported with 3d party software for use in drawing .obj 
  #D: file meshes.
  #---------------------------------------------------------------------------------------------------------
  def parse_mtl_file
    # check to make sure the file exists.
    file_dir = File.join(ROOT, "Media/Materials/#{@filename}.mtl") rescue nil
    unless FileTest.exists?(file_dir)
      puts("Material Load Error: Could not find source file.\n ( #{file_dir})")
      return nil
    end
    #---------------------------------------------------------
    # make sense of the materials library and break it into data objects for openGL drawing.
    @@material_files[@filename] = {}
    wo_lines = IO.readlines( wofilename )
    puts("+Loading .mtl file:\n  \"#{wofilename.sub(ROOT, '')}\"") if @@verbose
    # parse file context
    wo_lines.each do |line|
      tokens = line.split
      process_line(tokens[0], tokens[1..tokens.length-1])
    end
    #---------------------------------------------------------
    # cache the materials lib for later use.
    @@material_files[@filename] = new_material
    @current_material = nil
  end
  #---------------------------------------------------------------------------------------------------------
  #D: Read each line of an object file exported with 3d party software for loading into OpenGL draw methods.
  #D:  https://en.wikipedia.org/wiki/Wavefront_.obj_file#Material_template_library
  #---------------------------------------------------------------------------------------------------------
  def process_line( key, values )
    case key
    #---------------------------------------------------------
    when "newmtl" # sets material name, .mtl files can have multiple materials defined in them.
      @current_material = key
      @@material_files[@filename][@current_material] = Material.new(values.to_s)
    #--------------------------------------------------------- 
    when "Ka" # ambient color
      values.collect! { |v| v.to_f }
      @@material_files[@filename][@current_material].set(:ambient, values)
    #--------------------------------------------------------- 
    when "Kd" # difuse color
      values.collect! { |v| v.to_f }
      @@material_files[@filename][@current_material].set(:difuse, values)
    #--------------------------------------------------------- 
    when "Ks" # specular color
      values.collect! { |v| v.to_f }
      @@material_files[@filename][@current_material].set(:specular, values)
    when "Ns" # specular color wight
      values.to_f
      @@material_files[@filename][@current_material].set(:specular_weight, values)
    #--------------------------------------------------------- 
    when "d"  # transparent
      @@material_files[@filename][@current_material].set(:transparent, values.to_f)
    when "Tr" # some use inverted transparent values
      @@material_files[@filename][@current_material].set(:transparent, 1.0 - values.to_f)
    #--------------------------------------------------------- 
    when "illum"  #illumination models
      @@material_files[@filename][@current_material].set(:illumination, values.to_i)
    #---------------------------------------------------------
    else
      puts "  -Unsupported .mtl token #{key} given. Ignored."
    end
  end
  #=====================================================================================================================================================
  # Detail organizer for materials stored in the materlail library files.
  #=====================================================================================================================================================
  class Material
    attr_accessor :name, :colors, :transparent, :illuminations
    #---------------------------------------------------------------------------------------------------------
    #D: 
    #---------------------------------------------------------------------------------------------------------
    def initialize(lib_name = "")
      @name = lib_name
      @colors = [] # [ :ambient, :difuse,  :specular]
      @transparent = 0.0
      @illuminations = []
    end
    #---------------------------------------------------------------------------------------------------------
    #D: 
    #---------------------------------------------------------------------------------------------------------
    def set(key, value)
      case key
      #---------------------------------------------------------
      when :ambient
        @colors[0] = value
      #---------------------------------------------------------
      when :difuse
        @colors[1] = value
      #---------------------------------------------------------
      when :specular
        @colors[2] = value
      #---------------------------------------------------------
      when :specular_weight
        @colors[2].push(value)
      #---------------------------------------------------------
      when :transparent
        @transparent = value
      #---------------------------------------------------------
      when :illumination
        @illuminations.push(value)
      #---------------------------------------------------------
      else
        puts "  -Unsupported material token #{key} given. Ignored."
      end
    end
  end
#=====================================================================================================================================================
end # material lib loader