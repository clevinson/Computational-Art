############---------------------############
#
# Cory Levinson
# ARTDES 410
# Spin Cycle (Exercise 1)
# 
# NOTE: This script requires both the 'FlickRaw' and 'ruby-processing' gems.
#	After installing both of these gems, in bash enter: 'rp5 run path/to/file/cory_levinson_spin_cycle.rb'
#       for more help with ruby-processing, peep the wiki on github: https://github.com/jashkenas/ruby-processing/wiki
#
############--------------------############

require 'rubygems'
require 'FlickRaw'
require 'ruby-processing'

FlickRaw.api_key = "bfaa37fbd00c1291ced65b903fb15fda"

class Sketch1 < Processing::App

  def get_photo
    
    flickr = FlickRaw::Flickr.new    
    photos = flickr.photos.search( :tags => 'colorful' )
    @img_urls = photos.map { |photo| FlickRaw.url photo }
    load_image @img_urls[rand(100)]

  end

  def setup

    frame_rate 4
    @pic = get_photo
    size @pic.width, @pic.height, P2D 
    image @pic, 0, 0
    @been_clicked = false

  end
  
  def draw
   
    if @been_clicked
      radialize mouse_x, mouse_y
    end

  end 

  def radialize(x, y)
    
    (0..height-1).each do |new_y|
      (0..width-1).each do |new_x|

	theta = new_x*6.28/width
	r = new_y
	#These lines of code serve as calibration for the poloar coordinate transformation

	coord = [x + r*cos(theta), y + r*sin(theta)]
	fill_colorful = get coord[0], coord[1]
	brightness(fill_colorful) == 0 ? next : nil

	set new_x, new_y, fill_colorful

      end
    end

  end

  def mouse_clicked
    @been_clicked = !@been_clicked
  end

  def key_pressed
    if key == ' '  
      @pic = load_image @img_urls[rand(100)] 
      size @pic.width, @pic.height, P2D 
      image @pic, 0, 0
      @been_clicked = false
    end
  end

end

Sketch1.new :title => "Sketch 1"
