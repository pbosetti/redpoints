#!/usr/bin/env ruby
#
# Created by Paolo Bosetti on 2009-03-30.
# Copyright (c) 2009 University of Trento. All rights 
# reserved.

require 'rubygems'
require 'opengl'
require 'mathn'
require 'drb'
include Gl,Glu,Glut

TIMER_FREQUENCY_MILLIS = 50
SCALE_FACTOR = 0.05


class RedPoints
  attr_accessor :refresh_rate, :points, :point_size
  
  def RedPoints.open
    RedPoints.new.run
  end
  
  def initialize(args={})
    @axes_length = 100
    @fXDiff = 0
    @fYDiff = 0
    @fZDiff = 0
    @xLastIncr = 0
    @yLastIncr = 0
    @fScale = 1.0
    @xLast = -1
    @yLast = -1
    @bmModifiers = 0
    @draw = {:axes => true, :points => true, :lines => true }
    
    @x_pan = 0.0
    @y_pan = 0.0
    
    @refresh_rate = TIMER_FREQUENCY_MILLIS
    
    @points = []
    @point_size = 10.0
    
    glutInit
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_ALPHA)
    glutInitWindowSize(500, 500) 
    glutInitWindowPosition(100, 100)
    glutCreateWindow($0)
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glShadeModel     GL_SMOOTH
    glEnable         GL_DEPTH_TEST
    glEnable         GL_BLEND
    glEnable         GL_LINE_SMOOTH
    glBlendFunc      GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
    glutDisplayFunc  self.display 
    glutReshapeFunc  self.reshape 
    glutKeyboardFunc self.keyboard
    glutMotionFunc   self.motion  
    glutMouseFunc    self.mouse   
    glutTimerFunc    @refresh_rate, self.timer, 0
  end
  
  def status
    "#{@xLast}, #{@yLast}"
  end
  
  def run
    glutMainLoop()
    self
  end
  
  def display
    lambda do 
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_ACCUM_BUFFER_BIT)
      glPushMatrix()
      glRotate(@fXDiff, 1,0,0)
      glRotate(@fYDiff, 0,1,0)
      glRotate(@fZDiff, 0,0,1)
      glScale(@fScale, @fScale, @fScale)
      
      glPushMatrix()         # Begin rotation 90° about X
      glRotate(-90, 1,0,0)   # so to have Z axis pointing upward
      
      @points.each_with_index do |p,i|
        if @draw[:lines]
          if i < points.length - 1
            glColor(1,1,1,1)
            glBegin(GL_LINES)
              glVertex(points[i])
              glVertex(points[i+1])
            glEnd()
          end
        end
        if @draw[:points]
          glPushMatrix()
          glTranslate(*p) 
          glColor(1,0,0,0.9)
          glutSolidSphere(@point_size/@fScale, 16, 16)
          glPopMatrix()
        end
      end
      
      if @draw[:axes]
        glLineWidth(1.0)
        glColor(1,0,0,0.66)
        glBegin(GL_LINES)
          glVertex(0,0,0)
          glVertex(@axes_length/@fScale,0,0)
        glEnd()
        glPushMatrix()
        glTranslate(@axes_length/@fScale,0,0)
        glRotate(90,0,1,0)
        glutSolidCone(20/@fScale, 30/@fScale, 20, 1)
        glPopMatrix()
        
        glColor(0,1,0,0.66)
        glBegin(GL_LINES)
          glVertex(0,0,0)
          glVertex(0,@axes_length/@fScale,0)
        glEnd()
        glPushMatrix()
        glTranslate(0,@axes_length/@fScale,0)
        glRotate(-90,1,0,0)
        glutSolidCone(20/@fScale, 30/@fScale, 20, 1)
        glPopMatrix()
        
        glColor(0,0,1,0.66)
        glBegin(GL_LINES)
          glVertex(0,0,0)
          glVertex(0,0,@axes_length/@fScale)
        glEnd()
        glPushMatrix()
        glTranslate(0,0,@axes_length/@fScale)
        glRotate(0,0,1,0)
        glutSolidCone(20/@fScale, 30/@fScale, 20, 1)
        glPopMatrix()
      end
      
      glPopMatrix()  # end rotation about X
      glPopMatrix()
      glFlush()
      glutSwapBuffers()
    end
  end
  
  def reshape
    lambda do |w,h|
      glViewport(0, 0,  w,  h) 
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity()
      gluPerspective(65.0,  w/ h, 10.0, 2000.0)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity()
      glTranslate(0, 0, -2*@z_s[:z])
    end
  end
  
  def keyboard
    lambda do |key, x, y|
      case key
      when ?p
        @draw[:points] = !@draw[:points]
      when ?l
        @draw[:lines] = !@draw[:lines]
      when ?a
        @draw[:axes] = !@draw[:axes]
      when ?+
        @point_size *= 2.0
      when ?-
        @point_size /= 2.0
      when ?\e
        exit(0)
      end
    end
  end
  
  def motion
    lambda do |x, y|
      if (@xLast != -1 || @yLast != -1)
        @xLastIncr = x - @xLast
        @yLastIncr = y - @yLast
        if (@bmModifiers & GLUT_ACTIVE_CTRL != 0)
          if (@xLast != -1)
            @fScale += @yLastIncr*SCALE_FACTOR
            @fScale = @fScale.abs
            @x_pan = @y_pan = 0
          end
        elsif (@bmModifiers & GLUT_ACTIVE_SHIFT != 0)
          if (@xLast != -1)
            @x_pan = x   - glutGet(GLUT_WINDOW_WIDTH)/2.0
            @y_pan = - y + glutGet(GLUT_WINDOW_HEIGHT)/2.0
            glMatrixMode(GL_PROJECTION)
            glTranslate(0.1*@x_pan, 0.1*@y_pan, 0.0)
            glMatrixMode(GL_MODELVIEW)
          end
        else
          if (@xLast != -1)
            @fXDiff += @yLastIncr
            @fYDiff += @xLastIncr
            @x_pan = @y_pan = 0
          end
        end
      end
      @xLast = x
      @yLast = y
    end
  end
  
  def mouse
    lambda do |button, state, x, y|
      @bmModifiers = glutGetModifiers()
      if (button == GLUT_LEFT_BUTTON)
        if (state == GLUT_UP)
          @xLast = -1
          @yLast = -1
        end
        @xLastIncr = 0
        @yLastIncr = 0
      end
    end
  end
  
  def timer
    lambda do |value|
      glutPostRedisplay()
      glutTimerFunc(@refresh_rate, timer, 0)
    end
  end
  
end

if __FILE__ == $0
  server = RedPoints.new
  server_thread = Thread.new { server.run }
  DRb.start_service('druby://localhost:9000', server) 
  DRb.thread.join
  server_thread.kill
end