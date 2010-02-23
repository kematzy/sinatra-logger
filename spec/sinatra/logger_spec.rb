
require File.expand_path(File.dirname(File.dirname(__FILE__)) + '/spec_helper')

describe "Sinatra" do 
  
  class MyTestApp 
    register Sinatra::Logger
    
    helpers do 
      
      def dummy_helper(level, message) 
        logger.send(level, message)
        "Level: #{level},  Message: #{message}"
      end
    end
    
    get '/logger/:msg' do 
      logger.warn("Message: #{params[:msg]}")
      erb("Message: #{params[:msg]}", :layout => false )
    end
    
  end
  
  it_should_behave_like "MyTestApp"
  
  describe "Logger" do 
    
    describe "with Default Settings" do 
      
      before(:each) do 
        FileUtils.mkdir_p "#{fixtures_path}/log"
        @log_file = "#{fixtures_path}/log/#{MyTestApp.environment}.log"
        `touch #{@log_file}`
      end
      
      after(:each) do
        `echo '' > #{@log_file}`
      end
      
      describe "Configuration" do 
        
        it "should set :logger_level to :warn" do 
          app.settings.logger_level.should == :warn
        end
        
        it "should set :logger_log_file to [../log/< environment >.log]" do 
          app.settings.logger_log_file.should == "#{fixtures_path}/log/test.log"
        end
        
      end #/ Configuration
      
      describe "Helpers" do 
        
        describe "#logger" do 
          
          it "should create a #{MyTestApp.environment}.log file when initialized" do 
            test(?f, @log_file).should == true
          end
          
          it "should return an instance of Logger" do 
            app.should respond_to(:logger)
            app.logger.should be_a_kind_of(::Logger)
          end
          
          it "should log when called from within a route" do 
            get('/logger/this-works')
            body.should == "Message: this-works"
            IO.read(@log_file).should match(/WARN -- : Message: this-works/)
          end
          
          it "should log when called from within helper methods" do 
            erb_app '<%= dummy_helper(:warn, "works too") %>'
            IO.read(@log_file).should match(/WARN -- : works too/)
            body.should == "Level: warn,  Message: works too"
          end
          
          it "should NOT log lower levels" do 
            erb_app '<%= dummy_helper(:info, "default-info") %>'
            IO.read(@log_file).should_not match(/INFO -- : default-info/)
            body.should == "Level: info,  Message: default-info"
            
            erb_app '<%= dummy_helper(:debug, "default-debug") %>'
            IO.read(@log_file).should_not match(/DEBUG -- : default-debug/)
            body.should == "Level: debug,  Message: default-debug"
          end
          
        end #/ #logger
        
      end #/ Helpers
      
    end #/ with Default Settings
    
    describe "with Custom Settings" do 
      
      class MyCustomTestApp 
        register Sinatra::Logger
        
        set :logger_level, :debug
        set :logger_log_file, lambda { "#{fixtures_path}/log/custom.log" }
        
        helpers do 
          
          def dummy_helper(level, message) 
            logger.send(level, message)
            "Level: #{level},  Message: #{message}"
          end
        end
        
        get '/customlogger/:msg' do 
          logger.warn("Message: #{params[:msg]}")
          erb("CustomMessage: #{params[:msg]}", :layout => false )
        end
        
      end
      
      before(:each) do 
        class ::Test::Unit::TestCase 
          def app; ::MyCustomTestApp.new ; end
        end
        @app = app
        
        FileUtils.mkdir_p "#{fixtures_path}/log"
        @custom_log_file = "#{fixtures_path}/log/custom.log"
        `touch #{@custom_log_file}`
      end
      
      after(:each) do 
        class ::Test::Unit::TestCase 
          def app; nil ; end
        end
        @app = nil
        
        `echo '' > #{@custom_log_file}`
      end
      
      describe "Configuration" do 
        
        it "should set :logger_level to :debug" do 
          app.settings.logger_level.should == :debug
        end
        
        it "should set :logger_log_file to [../log/custom.log]" do 
          app.settings.logger_log_file.should == "#{fixtures_path}/log/custom.log"
        end
        
      end #/ Configuration
      
      describe "Helpers" do 
        
        describe "#logger" do 
          
          it "should create a custom.log file when initialised" do 
            test(?f, @custom_log_file).should == true
          end
          
          it "should return an instance of Logger" do 
            app.logger.should be_a_kind_of(::Logger)
          end
          
          it "should log when called from within a route" do 
            get('/customlogger/this-works')
            body.should == "CustomMessage: this-works"
            IO.read(@custom_log_file).should match(/WARN -- : Message: this-works/)
          end
          
          it "should log when called from within helper methods" do 
            erb_app '<%= dummy_helper(:info, "works as well") %>'
            IO.read(@custom_log_file).should match(/INFO -- : works as well/)
            body.should == "Level: info,  Message: works as well"
            
            erb_app '<%= dummy_helper(:warn, "works too") %>'
            IO.read(@custom_log_file).should match(/WARN -- : works too/)
            body.should == "Level: warn,  Message: works too"
          end
          
          it "should log higher levels" do 
            erb_app '<%= dummy_helper(:info, "custom-info") %>'
            IO.read(@custom_log_file).should match(/INFO -- : custom-info/)
            body.should == "Level: info,  Message: custom-info"
            
            erb_app '<%= dummy_helper(:debug, "custom-debug") %>'
            IO.read(@custom_log_file).should match(/DEBUG -- : custom-debug/)
            body.should == "Level: debug,  Message: custom-debug"
          end
          
        end #/ #logger
        
      end #/ Helpers
      
    end #/ with Custom Settings
    
  end #/ Logger
  
end #/ Sinatra
