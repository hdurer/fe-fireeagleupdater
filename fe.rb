#!/usr/bin/env ruby

# fe - a super-simple Fire Eagle updater for the command line
# written in 100% hacky Ruby
# no guarantees
# Copyright (c) Tom Morris 2008. All rights reserved.
# Licensed under the GNU General Public License v. 3.
# see http://www.gnu.org/copyleft/gpl.html
# 
# tom@tommorris.org - http://tommorris.org
# If you like this script, feel free to make a donation
# https://tipit.to/tommorris.org
# Original version @ http://tommorris.org/files/fe.rb.txt
#
# Modifications by Holger Durer:
# - no longer require obsolete version of oauth
# - more general concept of common locations (e.g. "fe @home", "fe @uni")
# - without arguments queries current location

require 'rubygems'
gem 'oauth'
require 'fireeagle'
require 'yaml'

usr = File.expand_path("~")

if File.file?(usr + "/.fireeagle")
  data = YAML.load_file(usr + "/.fireeagle")
  client = FireEagle::Client.new(:consumer_key => "wBj4qbOwSVEJ",
              :consumer_secret => "uIPDbtQVicFk4O32pa4nj9K6WjLLGwYT",
              :access_token => data['key'],
              :access_token_secret => data['secret'])
else
  client = FireEagle::Client.new(:consumer_key => "wBj4qbOwSVEJ",
              :consumer_secret => "uIPDbtQVicFk4O32pa4nj9K6WjLLGwYT")
  client.get_request_token()
  puts "Before you can use FireEagle at the command line, you need to authorize it."
  system "open \"" + client.authorization_url() + "\""
  puts "If your browser hasn't opened, copy and paste the URL into your browser."
  puts client.authorization_url()
  puts "when you are authorized, press ENTER"
  gets
  client.convert_to_access_token()
  data = {}
  data['key'] = client.access_token.token
  data['secret'] = client.access_token.secret
  puts "Please enter a default location, then press enter"
  puts "Leave blank to not set a default"
  default = gets.chop!
  if default.length != 0
    data['default'] = default
  end
  File.open(usr + "/.fireeagle", "w") {|f| YAML.dump(data, f) }
  puts "fe is now setup. Run it again to set your location:"
  puts "Usage: fe location"
  puts "e.g. fe \"London\" or fe \"Berlin\""
  puts "To query your current location, just run fe without arguments."
  puts "Edit ~/.fireeagle to define other default locations."
  if default.length != 0
  end
  exit
end

if ARGV.length == 0 
   user = client.location
   location = user.best_guess
   puts "Location: " + location.to_s + " (updated " + user.located_at.to_s + ")"
   geo = location.geom
   if geo.is_a?(GeoRuby::SimpleFeatures::Envelope)
     bbox = [geo.lower_corner, geo.upper_corner]
     geo = geo.center
   else
     bbox = geo.bounding_box
   end
   if bbox[0] == bbox[1]
     geo_desc = bbox[0].x.to_s + ", " + bbox[0].y.to_s
   else
     geo_desc = bbox[0].x.to_s + ", " + bbox[0].y.to_s + " - " + bbox[1].x.to_s + ", " + bbox[1].y.to_s 
   end
   puts "woeid: " + location.woeid.to_s + " @ " + geo_desc
else
  location = ARGV.to_s
  if location[0, 1] == "@"
     if data[location[1..-1]].nil?
        puts "Unknown alias " + location
        location = ""
     else
        location = data[location[1..-1]]
     end
  end
  if location.length == 0
     puts "You must give a location"
  else
    puts "Updating location to " + location
    client.update(:q => location)
  end
end
