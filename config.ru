puts 'starting...'
require File.expand_path('../application',  __FILE__)
puts 'environment: ' + Sinarey.env

use Rack::Deflater


map '/' do
  run PokerApp
end

puts 'starting...ok'

unless RUBY_PLATFORM =~ /mingw/
  memory_usage = (`ps -o rss= -p #{$$}`.to_i / 1024.00).round(2)
  puts "=> Memory usage: #{memory_usage} Mb"
end