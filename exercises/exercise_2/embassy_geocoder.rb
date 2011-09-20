require 'google_maps_geocoder'
require 'open-uri'
require 'json'

offices = JSON.parse(open('http://api.leakfeed.com/v1/cables/offices.json').read)

offices.map! { |office| office['display_name'] }

city_name = {}

offices.each { |office| city_name[office] = office.gsub('Embassy ', '').gsub('Consulate ', '') }

good_file = File.new('office_locations.txt', 'w')
bad_file = File.new('unfound_locations.txt', 'w')

geo_data = {}
bad_cities = []

city_name.each do |office, city|
  begin
    location = GoogleMapsGeocoder.new(city)
    geo_data[office] = [location.lat, location.lng]
  rescue RuntimeError
    bad_cities << city
    next
  end
end

file.syswrite(geo_data.to_s)
file.close

bad_file.syswrite(bad_cities.to_s)
bad_file.close
