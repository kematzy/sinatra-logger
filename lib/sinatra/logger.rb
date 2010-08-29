
require 'logger'

module Sinatra 
  
  # = Sinatra::Logger
  # 
  # A Sinatra extension that makes logging within Your apps easy.
  # 
  # 
  # == Installation
  # 
  #   #  Add Gemcutter to your RubyGems sources 
  #   $  gem sources -a http://gemcutter.com
  # 
  #   $  (sudo)? gem install sinatra-logger
  # 
  # == Dependencies
  # 
  # This Gem depends upon the following:
  # 
  # === Runtime:
  # 
  # * sinatra ( >= 1.0.a )
  # * logger
  # 
  # === Development & Tests:
  # 
  # * rspec (>= 1.3.0 )
  # * rack-test (>= 0.5.3)
  # * rspec_hpricot_matchers (>= 0.1.0)
  # * sinatra-tests (>= 0.1.6)
  # 
  # 
  # == Getting Started
  # 
  # To get logging in your app, just register the extension 
  # in your sub-classed Sinatra app:
  # 
  #   class YourApp < Sinatra::Base
  # 
  #     # NB! you need to set the root of the app first
  #     # set :root, '/path/2/the/root/of/your/app'
  #     
  #     register(Sinatra::Logger)
  #     
  #     <snip...>
  #     
  #   end
  # 
  # 
  # In your "classic" Sinatra app, you just require the extension like this:
  # 
  #   require 'rubygems'
  #   require 'sinatra'
  #   require 'sinatra/logger'
  # 
  #   # NB! you need to set the root of the app first
  #   # set :root, '/path/2/the/root/of/your/app'
  # 
  #   <snip...>
  # 
  # 
  # Then in your App's route or helper method declarations, just use the <tt>#logger</tt>...
  # 
  #   get '/some/route' do
  #     logger.debug("some informative message goes here")
  #     <snip...>
  #   end
  # 
  #   helpers do
  #     def some_helper_method
  #       logger.info("some equally informative message goes here")
  #       <snip...>
  #     end
  #   end
  # 
  # 
  # That's pretty painless, no?
  # 
  # 
  # === Logging Levels
  # 
  # The <b>default Log level</b> is <tt>:warn</tt>.
  # 
  # All the available logging levels are those of Logger[http://ruby-doc.org/stdlib/libdoc/logger/rdoc/classes/Logger.html], which are:
  # 
  # * <tt>logger.fatal(msg)</tt> - - (FATAL) - an unhandleable error that results in a program crash
  # 
  # * <tt>logger.error(msg)</tt> - - (ERROR) - a handleable error condition
  # 
  # * <tt>logger.warn(msg)</tt> - - (WARN) - a warning
  # 
  # * <tt>logger.info(msg)</tt> - - (INFO) - generic (useful) information about system operation
  # 
  # * <tt>logger.debug(msg)</tt> - - (DEBUG) - low-level information for developers
  # 
  # 
  # OK, by now you might be asking yourself, 
  # 
  # <em>"So where does the log messages go then ?"</em>.
  # 
  # 
  # === Logging Locations
  # 
  # By default the logger will log it's message to the following path:
  # 
  #   < the root of your app >/log/< environment >.log
  # 
  # In other words if your app's root is [ <tt>/home/www/your-great-app/</tt> ] and it's 
  # running in <tt>:production</tt> mode, then the log location would become:
  # 
  #   /home/www/your-great-app/log/production.log
  # 
  # <b>NB!</b> this extension takes for granted that you have a ../log/ directory with write access at the root of your app.
  # 
  # 
  # === Custom Logging Location
  # 
  # If the defaults are NOT for you, then just do...
  # 
  #   class YourApp < Sinatra::Base
  # 
  #     register(Sinatra::Logger)
  # 
  #     set: :logger_log_file, lambda { "/path/2/your/log/file.ext" }
  # 
  #     <snip...>
  # 
  #   end
  # 
  # 
  #   # the lambda { } is required, especially if you have variables in the path
  # 
  # ..., now your log messages will be written to that log file.
  # 
  # 
  # === Setting Log Level
  # 
  # Finally, to use a different Log level for your app, other than the default <tt>:warn</tt> just...
  # 
  #   class YourApp < Sinatra::Base
  # 
  #     register(Sinatra::Logger)
  # 
  #     set: :logger_level, :fatal # or :error, :warn, :info, :debug
  #     <snip...>
  #   end
  # 
  # 
  # That's it. I hope that's easy enough.
  # 
  module Logger 
    
    VERSION = '0.1.0'
    ##
    # Returns the version string for this extension
    # 
    # ==== Examples
    # 
    #   Sinatra::Logger.version  => 'Sinatra::Logger v0.1.0'
    # 
    def self.version; "Sinatra::Logger v#{VERSION}"; end
    
    
    module Helpers 
      
      ##
      # Provides easy access to the Logger object throughout your 
      # application
      #  
      # ==== Examples
      # 
      #   logger.warn("messsage")
      # 
      # 
      # @api public
      def logger 
        @logger ||= begin
          @logger = ::Logger.new(self.class.logger_log_file)
          @logger.level = ::Logger.const_get((self.class.logger_level || :warn).to_s.upcase)
          @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
          @logger
        end
      end
      
    end #/module Helpers
    
    
    def self.registered(app)
      app.helpers Sinatra::Logger::Helpers
      
      # set the output log level
      app.set :logger_level, :warn
      # set the full path to the log file
      app.set :logger_log_file, lambda { File.join(root, 'log', "#{environment}.log") }
      
    end #/ self.registered
    
  end #/module Logger
  
  register(Sinatra::Logger)
  
end #/ Sinatra
