#=====================================================================================================================================================
# !!!   3dObject.rb  |  Basic OpenGL object displayed in 3D.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Object3D < Basic3D_Object
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Creates Kernal class Object. (Klass)
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    super(options)
    type = "cardboard"
    # save the @texture refrence as its refered to later and you dont want to loose the refrence object.
    @texture = Gosu::Image.new(File.join(ROOT, "Media/Textures/#{type}.png"), retro: true) rescue nil
    if @texture.nil?
      puts("Texture image file was not found for: #{type}")
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
    # in OpenGL, you only draw at [0, 0, 0], no matter what...
    # you stretch and pull the viewing texture (x,y,z) values to construct the world in 3D.
    # this requires math.. lol at a later time might work on version for help with that.
    # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/GLTexInfo
    glBindTexture(GL_TEXTURE_2D, @tex_info.tex_name)
      glPushMatrix
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glvertex3f
      glScalef(@texture.width, @texture.height, 1)
      glBegin(GL_QUADS)
        glTexCoord2d(@tex_info.left, @tex_info.top)
        glVertex3f(-0.5, 0.5, 0.0)
        glTexCoord2d(@tex_info.left, @tex_info.bottom)
        glVertex3f(-0.5, -0.5, 0.0)
        glTexCoord2d(@tex_info.right, @tex_info.bottom)
        glVertex3f(0.5, -0.5, 0.0)
        glTexCoord2d(@tex_info.right, @tex_info.top)
        glVertex3f(0.5, 0.5, 0.0)
      glEnd
    glPopMatrix
    # more openGL drawing
    wire_frame_cube
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Empty wire frame object rendering sample.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def wire_frame_cube
    glBindTexture(GL_TEXTURE_2D, @tex_info.tex_name)
    glBegin(GL_QUADS)
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
