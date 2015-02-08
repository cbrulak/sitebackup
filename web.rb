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
  "Learning Ruby on Heroku"
  
end


post '/backup' do
  
  url = params[:url]
  
  puts "url is " + url
  dir = "./tmp3/" 
  FileUtils::mkdir_p dir
  doc = RemoteDocument.new(URI.parse(url))
  if (doc.mirror(dir) != 0)
    "saved " + url
  else
    "error downloading " + url
  end
  
end
