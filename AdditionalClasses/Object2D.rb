#=====================================================================================================================================================
# !!!   2dObject.rb  |  Basic OpenGL 2D texture plane object displayed in 3D world.
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Version 0.0
# Date: 0/0/0
#=====================================================================================================================================================
class Object2D < Basic3D_Object
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Creates Kernal class Object. (Klass)
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def initialize(options = {})
    super(options)
    file_name = options[:filename] || options[:texture] || "" 
    # save the @texture refrence as its refered to later and you dont want to loose the refrence object.
    @texture = Gosu::Image.new(File.join(ROOT, "Media/Textures/#{file_name}.png"), retro: true) rescue nil
    if @texture.nil?
      puts("Texture image file was not found for: #{file_name}")
      puts caller # back trace
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
    super
    
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called from $program Gosu::Window inside the draw method que. This is called after the interjection of gl_draw function.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def draw

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
      # Moving function from the current point by current Camera gluPerspective x,y,z
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/gltranslatef
      glTranslatef(@x, @y, @z)
      #---------------------------------------------------------
      # https://www.rubydoc.info/github/gosu/gosu/master/Gosu/GLTexInfo
      glBindTexture(GL_TEXTURE_2D, @tex_info.tex_name)
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glscalef
      glScalef(@scale, @scale, @scale)
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glrotatef
      # glRotatef(angle, X axis scale, Y axis scale, Z axis scale)
      glRotatef(@angle.first, @angle[1], @angle[2], @angle[3])
      #---------------------------------------------------------
      # https://docs.microsoft.com/en-us/windows/desktop/opengl/glbegin
      glBegin(GL_QUADS)
        # https://docs.microsoft.com/en-us/windows/desktop/opengl/glvertex3f
        glTexCoord2d(@tex_info.left, @tex_info.top); glVertex3f(-0.5, 0.5, 0.0)
        glTexCoord2d(@tex_info.left, @tex_info.bottom); glVertex3f(-0.5, -0.5, 0.0)
        glTexCoord2d(@tex_info.right, @tex_info.bottom); glVertex3f(0.5, -0.5, 0.0)
        glTexCoord2d(@tex_info.right, @tex_info.top); glVertex3f(0.5, 0.5, 0.0)
      glEnd
      #---------------------------------------------------------
    # https://docs.microsoft.com/en-us/windows/desktop/opengl/glpopmatrix
    glPopMatrix
  end
  #-------------------------------------------------------------------------------------------------------------------------------------------
  #D: Called when its time to release the object to GC.
  #-------------------------------------------------------------------------------------------------------------------------------------------
  def destroy

  end
end
