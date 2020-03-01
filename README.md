# Gosu-and-OpenGL


This was written as a sample for using the Gosu library to develop 3D software useing the OpenGL library in Ruby.


### Requirements
This OpenGL ruby gem.
https://rubygems.org/gems/opengl-bindings
Docs: http://docs.gl/

And Gosu with a compatible Ruby version.
https://rubygems.org/gems/gosu

https://www.ruby-lang.org/en/documentation/installation/

### To Run

In a Terminal or system Console 'cd' into the project directory and use 'ruby run.rb' to launch the Gosu::Window.


### Notes

This is a work in progress but provides some basic layout samples for a 3D rendering system with Camera and Object support.

If you have issues with `undefined method 'load_lib' for Gl:Module`
ensure that you only have one OpenGl gem installed by using command 'gem search opengl --local' the only thing returned is:
>opengl-bindings

### Screen Shot

![alt text](https://raw.githubusercontent.com/wigggles/Gosu-and-OpenGL/master/Media/Screen_Shots/Screen_Shot.png "")


### Work in Progress

Sledge map support:

https://logicandtrick.github.io/sledge/