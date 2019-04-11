#=====================================================================================================================================================
# !!!   2dObject.rb  |  Basic OpenGL 2D texture plane object displayed in 3D world.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Object2D < Basic3D_Object
  DEBUG_SPIN = true # spin the view of objects perspective for viewing tests.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Creates Kernal class Object. (Klass)
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    super(options)
    file_name = options[:filename] || options[:texture] || "" 
    @angle = 0
    @scale = options[:scale] || 1.0 # scale to stretch the texture to.
    # save the @texture refrence as its refered to later and you dont want to loose the refrence object.
    @texture = Gosu::Image.new(File.join(ROOT, "Media/Textures/#{file_name}.png"), retro: true) rescue nil
    if @texture.nil?
      puts("Texture image file was not found for: #{file_name}")
      exit
    end
    #--------------------------------------
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/Image#gl_tex_info-instance_method
    @tex_info = @texture.gl_tex_info # helper structure that contains image data
    # This vlaue is tied into the storage method of the Gosu::Image object and can not be changed.
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Usually called from a loop to push variable changes and automate function triggers.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def update
		
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called from $program Gosu::Window inside the draw method que. This is called after the interjection of gl_draw function.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def draw

  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called from $program Gosu::Window inside draw, this happens before any Gosu::Font or Gosu::Image actions
  #D: take place.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def gl_draw
    #---------------------------------------------------------
    @angle += 1 if DEBUG_SPIN
    # rotate all 3D drawing after this call on viewing axis angle.
    $program.camera3d_rotate_view(@angle)
    # Moving function from the current point by current Camera gluPerspective x,y,z
    glTranslatef(0, 0, 0)
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/GLTexInfo
    glBindTexture(GL_TEXTURE_2D, @tex_info.tex_name)
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glscalef
    glScalef(@scale, @scale, @scale)
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glbegin
    glBegin(GL_QUADS)
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glvertex3f
      glTexCoord2d(@tex_info.left, @tex_info.top); glVertex3f(-0.5, 0.5, 0.0)
      glTexCoord2d(@tex_info.left, @tex_info.bottom); glVertex3f(-0.5, -0.5, 0.0)
      glTexCoord2d(@tex_info.right, @tex_info.bottom); glVertex3f(0.5, -0.5, 0.0)
      glTexCoord2d(@tex_info.right, @tex_info.top); glVertex3f(0.5, 0.5, 0.0)
    glEnd
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called when its time to release the object to GC.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def destroy

  end
end
