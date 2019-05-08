#=====================================================================================================================================================
# This was provided by BestGuiGUi (415559768233476106)
# As gosu does not do well with indexing texture images, this class handles OpenGL textures.
# Their help with understanding OpenGL call functions is what built most of this project.
# If you see them in the Gosu lib Discord server be sure to say hello!
#=====================================================================================================================================================
module Yume
  class Texture
    attr_reader :tex_name, :width, :height
    def initialize(texture_path)
      texture = texture_path.is_a?(Gosu::Image) ? texture_path : Gosu::Image.new(texture_path, retro: true) 
      array_of_pixels = texture.to_blob
      tex_name_buf = ' ' * 4
      glGenTextures(1, tex_name_buf)
      @tex_name = tex_name_buf.unpack('L')[0]
      glBindTexture(GL_TEXTURE_2D, @tex_name)
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture.width, texture.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)

      gl_version = glGetString(GL_VERSION).to_s
      gl_version = gl_version.split(' ')
      if Gem::Version.new(gl_version[0]) > Gem::Version.new("1.5.0")
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
        glGenerateMipmap(GL_TEXTURE_2D) # throws segment fault on older opengl versions
      else
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
      end

      @width, @height = texture.width, texture.height
    end

    def self.load_tiles(filename, tile_width, tile_height)
      textures = Array.new
      Gosu::Image.load_tiles(filename, tile_width, tile_height, retro: true).each do |gosu_image|
        textures.push Texture.new(gosu_image)
      end
      return textures
    end
  end
end