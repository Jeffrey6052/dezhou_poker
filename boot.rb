require 'yaml'
require 'logger'

module Sinarey

  @root = File.expand_path('.', __dir__)
  @env = 'development'
  
  if ENV['SINAREY_ENV']=='heroku'
    puts "SINAREY_ENV = heroku"
    @secret = File.open(@root+'/heroku/secret').readline.chomp
    @dbyml = YAML::load(File.open(@root+'/heroku/database.yml'))
  else
    @secret = File.open(@root+'/secret').readline.chomp
    @dbyml = YAML::load(File.open(@root+'/database.yml'))
  end
  @session_key = 'rack.session'
  @dbconfig = @dbyml[@env]

  @dblogger = nil
  @logger = ::Logger.new(STDOUT)


  class << self
    attr_reader :dbyml,:root,:secret,:logger,:dblogger,:session_key
    attr_accessor :env,:dbconfig
  end
  
end


require 'bundler'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('Gemfile', __dir__)

require 'bundler/setup'

