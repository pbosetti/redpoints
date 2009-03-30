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

TIMER_FREQUENCY_MILLIS = 20
SCALE_FACTOR = 0.05


class RedPoints
  def RedPoints.open
    RedPoints.new.run
  end
  
  def initialize(args={})
    @axes_length = 500
    @fXDiff = 0
    @fYDiff = 35
    @fZDiff = 0
    @xLastIncr = 0
    @yLastIncr = 0
    @fScale = 1.0
    @ftime = 0
    @xLast = -1
    @yLast = -1
    @bmModifiers = 0
    @rotate = true
    @draw = {:axes => true}
    
    @x_s = {:x => 600, :y => 40, :z => 100} 
    @y_s = {:x => 50, :y => 600, :z => 50}
    @z_s = {:x => 40, :y => 40, :z => 600}
    @range = {:x => 500, :y => 500, :z => 500}
    @x_pan = 0.0
    @y_pan = 0.0
    
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
    glutTimerFunc    TIMER_FREQUENCY_MILLIS , self.timer, 0
  end
  
  def run
    glutMainLoop()
    self
  end
  
  def display
    lambda do 
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_ACCUM_BUFFER_BIT)
      glPushMatrix()
      glRotate(@fYDiff, 1,0,0)
      glRotate(@fXDiff, 0,1,0)
      glRotate(@fZDiff, 0,0,1)
      glScale(@fScale, @fScale, @fScale)
      glMatrixMode(GL_PROJECTION)
      glTranslate(0.1*@x_pan, 0.1*@y_pan, 0.0)
      glMatrixMode(GL_MODELVIEW)

      if @draw[:axes]
        glLineWidth(1.0)
        glColor(1,0,0,0.66)
        glBegin(GL_LINES)
          glVertex(-@axes_length,0,0)
          glVertex(@axes_length,0,0)
        glEnd()
        glPushMatrix()
        glTranslate(@axes_length,0,0)
        glRotate(90,0,1,0)
        glutSolidCone(20, 30, 20, 1)
        glPopMatrix()
        
        glColor(0,1,0,0.66)
        glBegin(GL_LINES)
          glVertex(0,-@axes_length,0)
          glVertex(0,@axes_length,0)
        glEnd()
        glPushMatrix()
        glTranslate(0,@axes_length,0)
        glRotate(-90,1,0,0)
        glutSolidCone(20, 30, 20, 1)
        glPopMatrix()
        
        glColor(0,0,1,0.66)
        glBegin(GL_LINES)
          glVertex(0,0,-@axes_length)
          glVertex(0,0,@axes_length)
        glEnd()
        glPushMatrix()
        glTranslate(0,0,@axes_length)
        glRotate(0,0,1,0)
        glutSolidCone(20, 30, 20, 1)
        glPopMatrix()
      end

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
      when ?a
        @draw[:axes] = !@draw[:axes]
      when ?\e
        exit(0)
      end
      glutPostRedisplay()
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
            @x_pan = x - glutGet(GLUT_WINDOW_WIDTH)/2.0
            @y_pan = - y + glutGet(GLUT_WINDOW_HEIGHT)/2.0
          end
        else
          if (@xLast != -1)
            @fXDiff += @xLastIncr
            @fYDiff += @yLastIncr
            @x_pan = @y_pan = 0
          end
        end
      end
      @xLast = x
      @yLast = y
      glutPostRedisplay()
    end
  end
  
  def mouse
    lambda do |button, state, x, y|
    
    end
  end
  
  def timer
    lambda do |value|
      glutPostRedisplay()
    end
  end
  
end

rp = RedPoints.open