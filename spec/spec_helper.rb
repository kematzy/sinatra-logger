

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))


#--
# DEPENDENCIES
#++
%w( 
sinatra/base 
fileutils
).each {|lib| require lib }

#--
## SINATRA EXTENSIONS
#++
%w(
sinatra/tests
sinatra/logger
).each {|ext| require ext }


ENV['RACK_ENV'] = 'test'

Spec::Runner.configure do |config|
  config.include RspecHpricotMatchers
  config.include Sinatra::Tests::TestCase
  config.include Sinatra::Tests::RSpec::SharedSpecs
end

def fixtures_path 
  "#{File.dirname(File.expand_path(__FILE__))}/fixtures"
end

class MyTestApp < Sinatra::Base 
  set :root, "#{fixtures_path}"
  set :app_dir, "#{fixtures_path}/app"
  set :public, "#{fixtures_path}/public"
  set :views, "#{app_dir}/views"
  enable :raise_errors
  
  register(Sinatra::Tests)
  
end #/class MyTestApp

class MyCustomTestApp < Sinatra::Base 
  set :root, "#{fixtures_path}"
  set :app_dir, "#{fixtures_path}/app"
  set :public, "#{fixtures_path}/public"
  set :views, "#{app_dir}/views"
  enable :raise_errors
  
  register(Sinatra::Tests)
  
end #/class MyCustomTestApp


class Test::Unit::TestCase 
  Sinatra::Base.set :environment, :test
end
