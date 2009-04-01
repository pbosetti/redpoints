#!/usr/bin/env ruby
#
# Created by Paolo Bosetti on 2009-03-30.
# Copyright (c) 2009 University of Trento. All rights 
# reserved.

require 'drb'
include Math

# Setup of the remote viewer
DRb.start_service() 
rp = DRbObject.new(nil, 'druby://localhost:9000') 

# Create a path
points = []
100.times do |i|
  r = 100+rand*10
  a = 4*2*PI*i/100
  points << [r*sin(a), r*cos(a), i]
end

# Now use th remote viewer
rp.draw = {:axes => true, :points => true, :lines => true }
rp.points = points
