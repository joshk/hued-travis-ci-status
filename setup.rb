require 'hue'
require 'json'

hue = nil

begin
  puts "Locating the Hue bridge"

  hue = Hue::Client.new("travis-ci-on-the-piiii")

  puts "Hue bridge found at #{client.bridge.ip}\n\n"
rescue Hue::NoBridgeFound => e
  puts "Sorry but no Hue bridge could be found"
  exit
rescue => e
  # nothing for now
end

begin
  hue = Hue::Client.new("travis-ci-on-the-pi")

  puts "Looks like the bridge knows who you are!\n\n"
rescue Hue::LinkButtonNotPressed => e
  puts "This is the first time setting this up, so you need to please the link button"
  sleep 2
  retry
end

lights = hue.lights
case lights.size
when 0
  puts "Sorry but it doesn't look like any lights are connected to your Hue"
  exit
when 1
  puts "Found a light!\n\n"
else
  puts "Ohhhh, found #{lights.size} lights!\n\n"
end

monitored_lights = []

lights.each do |light|
  light.set_state alert: 'lselect'
  sleep 2
  light.set_state alert: 'none'
  print "Would you like to setup '#{light.name}' to link to a repo on travis-ci.org? (y/n) : "
  STDOUT.flush
  answer = gets.chomp.downcase
  case answer
  when 'y'
    print "What is the repo you would like to link this light to? eg. travis-ci/travis-api : "
    STDOUT.flush
    repo = gets.chomp.downcase
    puts "\n"
    light.name = "travis-ci: #{repo.split('/').last}"[0..30]
    monitored_lights << { light_id: light.id, repo: repo }
  else
    next
  end
end

settings = {
  lights: monitored_lights 
}

File.open("settings.json","w") do |f|
  f.write(settings.to_json)
end

message = "setup to sync with Travis CI repos"

case monitored_lights.size
when 0
  puts "No lights #{message}"
when 1
  puts "1 light #{message}"
else
  puts "#{monitored_lights.size} lights #{message}"
end

