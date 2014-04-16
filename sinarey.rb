
require 'sinarey'

require 'erb_safe_ext'
require 'erb_safe_ext/sinatra/exception_template'

require "sinatra/multi_route"
require "sinatra/content_for"
require "sinatra/cookies"

require 'sinarey_support'
require 'sinarey_cache'

require 'sequel'
require 'will_paginate'
require 'timerizer'
require 'oj'

require 'rack-flash'

#require 'newrelic_rpm' #线上监控

db_opts = {adapter:'postgres',host:Sinarey.dbconfig['host'],port:Sinarey.dbconfig['port'],database:Sinarey.dbconfig['database'],user:Sinarey.dbconfig['username'],password:Sinarey.dbconfig['password'],max_connections:Sinarey.dbconfig['pool']||1,logger:Sinarey.dblogger}
DB = Sequel.connect(db_opts)

DB.extension(:pagination)
Sequel::Model.plugin :timestamps, update_on_create:true


#add custom options to Sinatra::Cookies
module Sinatra
  module Cookies
    class Jar

      def store(key,value,options={})
        @response.set_cookie key.to_s, @options.merge(options).merge(:value => value)
      end

      def remove(key,options={})
        result = self[key]
        @response.delete_cookie(key.to_s, @options.merge(options))
        result
      end

    end
  end
end

module Sinarey

  class Application < Sinatra::SinareyBase

    set :default_encoding, 'utf-8'

    helpers Sinatra::ContentFor

    register WillPaginate::Sinatra
    register Sinatra::MultiRoute

    helpers Sinatra::Cookies
    set :cookie_options, {path:'/',expires:1.year.from_now,httponly:false}

    use Rack::Session::Cookie, { path:'/', expire_after:nil, key:Sinarey.session_key, secret:Sinarey.secret }

    use Rack::Flash

    set :static, false

    #logger configure
    set :logging, nil

    case Sinarey.env
    when 'production'
      set :show_exceptions, false
      set :raise_errors, false
      set :dump_errors, false
    else
      require "sinatra/reloader"
      register Sinatra::Reloader
      Dir["#{Sinarey.root}/app/*/*.rb"].each {|f| also_reload f }
      set :show_exceptions, true
      set :raise_errors, true
      set :dump_errors, false
    end

    #use custom logic for finding template files
    def find_template(views, name, engine, &block)
      paths = views.map { |d| Sinarey.root + '/app/views/' + d }
      Array(paths).each { |v| super(v, name, engine, &block) }
    end

    helpers do

      def escape_javascript(javascript)
        if javascript
          javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"'])/u) {|match| JS_ESCAPE_MAP[match] }
        else
          ''
        end
      end

      def flash
        env['x-rack.flash'] || {}
      end

      def writelog(msg)
        Sinarey.logger << (msg.to_s + "\n")
      end

      def dump_errors
        boom = env['sinatra.error']
        if boom.present?
          msg = ["#{boom.class} - #{boom.message}:", *boom.backtrace].join("\n\t")
          writelog(msg)
        end
      end

    end
    
  end
end

JS_ESCAPE_MAP = {
  '\\'    => '\\\\',
  '</'    => '<\/',
  "\r\n"  => '\n',
  "\n"    => '\n',
  "\r"    => '\n',
  '"'     => '\\"',
  "'"     => "\\'"
}

JS_ESCAPE_MAP["\342\200\250".force_encoding(Encoding::UTF_8).encode!] = '&#x2028;'
JS_ESCAPE_MAP["\342\200\251".force_encoding(Encoding::UTF_8).encode!] = '&#x2029;'

class ApplicationController < Sinarey::Application ; end #init