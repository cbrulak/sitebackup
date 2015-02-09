require './web.rb'
enable :logging, :dump_errors, :raise_errors
run Sinatra::Application
