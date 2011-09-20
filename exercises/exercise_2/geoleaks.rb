require 'rubygems'
require 'google_maps_geocoder'
require 'yaml'
require 'open-uri'
require 'json'
require "~/Computational-Art/exercises/exercise_2/code/modestmaps.jar"
#  make sure to change the above require string to match where your copy of modestmaps.jar is

MM = com.modestmaps
$search_term = "phone tap"

class CableSearch

  def initialize(search_term)
    search_term.gsub!(" ","%20")
    result_string = open("http://api.leakfeed.com/v1/cables/find.json?query='#{search_term}'").read
    @data = JSON.parse(result_string)
  end

  def cables
    @data['cables']
  end

end

def setup

  size(1280, 1024)
  smooth

  @map = MM.InteractiveMap.new(self, MM.providers.Microsoft::HybridProvider.new ) 

  results = CableSearch.new($search_term)
  cities = results.cables.map { |cable| cable['office'] }
  cities -= ["Secretary of State", "USUN New York", "Mission USNATO", "Mission UNESCO", "US Delegation, Secretary", "REO Basrah"]

  @weighted_cities = {}
  cities.each { |city| @weighted_cities[city].nil? ? @weighted_cities[city] =  cities.count(city) : nil}

  @office_loc = eval open(File.dirname(__FILE__) + '/data/office_locations.txt').read

end

def draw

  background 0
  @map.draw
  smooth

  @weighted_cities.each do |city, weight|
    loc = @office_loc[city]
    location = MM.geo.Location.new(loc[0], loc[1])
    p = @map.locationPoint(location)

    fill(0,255,10,95)
    stroke(50,50,0)
    ellipse(p.x, p.y, weight, weight)
    stroke(0,255,0)
    ellipse(p.x, p.y, 1, 1)
  end

  if key_pressed?
    if key == CODED
      case key_code when LEFT  ; @map.tx += 5.0/@map.sc
		    when RIGHT ; @map.tx -= 5.0/@map.sc
		    when UP    ; @map.ty += 5.0/@map.sc
		    when DOWN  ; @map.ty -= 5.0/@map.sc
      end
    elsif key == '+' || key == '='
      @map.sc *= 1.05
    elsif key == '_' || key == '-' && @map.sc > 2
      @map.sc *= 1.0/1.05
    end
  end

end

def mouseDragged
  @map.mouseDragged 
end

def mouseWheel(delta)
  if delta > 0
    @map.sc *= 1.05
  elsif delta < 0
    @map.sc *= 1.0/1.05 
  end
end


