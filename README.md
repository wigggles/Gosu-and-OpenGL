# Gosu-and-OpenGL


This was written as a sample of using Gosu for developing 3D software useing the OpenGl library.


### Requirements
This OpenGL ruby gem.
https://rubygems.org/gems/opengl-bindings

And Gosu and a compatible Ruby version.
https://rubygems.org/gems/gosu

### To Run

In a Terminal or system Console 'cd' into the project directory and use 'ruby run.rb' to launch the Gosu::Window.


### Notes

This is a work in progress but provides some basic layout samples for a 3D rendering system with Camera and Object support.

If you have issues with `undefined method 'load_lib' for Gl:Module`
ensure that you only have one OpenGl gem installed by using command 'gem search opengl --local' the only thing returned is:
>opengl-bindings

### Screen Shot

![alt text](https://raw.githubusercontent.com/wigggles/Gosu-and-OpenGL/master/Media/Screen_Shots/Screen_Shot.png "")
