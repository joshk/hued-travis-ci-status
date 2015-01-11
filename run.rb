require 'hue'
require 'json'
require 'travis/client'

hue = nil

unless File.exists?('settings.json')
  puts "Please setup which Hue lights you want to link on Travis CI first"
  exit
end

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
  puts "Please setup which Hue lights you want to link on Travis CI first"
  exit
end

transition_time = 2
passed = { hue: 25500, brightness: 255, saturation: 255 }
failed = { hue: 65535, brightness: 255, saturation: 255 }

file = File.read('settings.json')
monitored_lights = JSON.parse(file)['lights']

message = "setup to sync with Travis CI repos"

case monitored_lights.size
when 0
  puts "No lights #{message}"
  puts "Please setup which Hue lights you want to link on Travis CI first"
  exit
when 1
  puts "1 light #{message}"
else
  puts "#{monitored_lights.size} lights #{message}"
end

puts "Starting monitoring: #{monitored_lights.collect { |ml| ml["repo"] }}"
travis = Travis::Client.new
loop do
  monitored_lights.each do |ml|
    puts "checking status of #{ml["repo"]}"
    repo = travis.repo(ml["repo"])
    master = repo.branch('master')
    puts "the most recent master build on #{ml["repo"]} #{master.state}"
    case master.state
    when 'passed'
      hue.light(ml["light_id"]).set_state passed
    when 'failed'
      hue.light(ml["light_id"]).set_state failed
    end
  end
  sleep 2
end
