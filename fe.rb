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

require 'rubygems'
gem 'oauth', '=0.2.2'
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
  if default.length != 0
    puts "To set to your default, just run fe without arguments"
  end
  exit
end

if ARGV.length == 0 and data['default'].nil? == false
   puts "Location set to default"
   client.update(:q => data['default'])
elsif ARGV.length == 1
  puts "Location: " + ARGV[0]
  client.update(:q => ARGV[0])
elsif ARGV.length > 1
  puts "Location: " + ARGV.to_s
  client.update(:q => ARGV.to_s)
else
  print "Where are you, then?"
end
