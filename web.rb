require 'sinatra'
require_relative 'RemoteDocument.rb'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'fileutils'
require 'pry'

if ENV['ENV'] == 'prod'
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == ENV['username'] && password == ENV['password']
  end
end

get '/' do
  "backup service"
  
end


post '/backup' do
  
  url = params[:url]
  
  dir = "./tmp/" 
  doc = RemoteDocument.new(URI.parse(url))
  if (doc.mirror(dir) != 0)
    
    status 200
  else
    
    status 400
  end
  
end
