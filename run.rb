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

TRANSITION_TIME = 2
PASSED = { hue: 25500, brightness: 255, saturation: 255 }
FAILED = { hue: 65535, brightness: 255, saturation: 255 }

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

def repo_status(travis, slug)
  repo = travis.repo(slug)
  master = repo.branch('master')
  master.state
rescue => e
  puts "had an error fetching the status of repo:#{slug}, moving on"
  raise
end

def update_light(hue, light_id, state)
  case state
  when 'passed'
    hue.light(light_id).set_state PASSED, TRANSITION_TIME
  when 'failed'
    hue.light(light_id).set_state FAILED, TRANSITION_TIME
  end
rescue => e
  puts "had an error updating light:#{light_id}, moving on"
  raise
end

puts "Starting monitoring: #{monitored_lights.collect { |ml| ml["repo"] }}\n\n"
travis = Travis::Client.new
loop do
  travis.clear_cache
  monitored_lights.each do |ml|
    begin
      puts "checking status of #{ml["repo"]}"
      state = repo_status(travis, ml["repo"])
      puts "the most recent master build on #{ml["repo"]} #{state}"
      update_light(hue, ml["light_id"], state)
    rescue => e
      # nothing for now
    end
  end
  sleep 3
end
