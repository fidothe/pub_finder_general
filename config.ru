root_path = File.expand_path('../', __FILE__)
$:.unshift(root_path) unless $:.include?(root_path)
require 'app'

puts "STUFFS"

run Sinatra::Application