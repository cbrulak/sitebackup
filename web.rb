require 'sinatra'
require_relative 'RemoteDocument.rb'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'fileutils'
require 'pry'
require 'aws/s3'
require_relative 'S3FolderUpload.rb'

if ENV['ENV'] == 'prod'
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == ENV['username'] && password == ENV['password']
  end
end

get '/' do
  "backup service"
  
end


configure do
  # logging is enabled by default in classic style applications,
  # so `enable :logging` is not needed
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end


post '/backup' do
  
  url = params[:url]
  
  dir = "./tmp/" 
  doc = RemoteDocument.new(URI.parse(url))
  fileName = doc.mirror(dir)
  if (!fileName.nil?)
    #upload(fileName,dir)
    uploader = S3FolderUpload.new(dir, ENV['BUCKET_NAME'], ENV['ACCESS_KEY_ID'], ENV['SECRET_ACCESS_KEY'])
    uploader.upload!
    status 200
  else
    
    status 400
  end
  
end

def upload(filename, file)
  #binding.pry
    bucket =  ENV['BUCKET_NAME']
    AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['ACCESS_KEY_ID'],
      :secret_access_key => ENV['SECRET_ACCESS_KEY']
    )
    AWS::S3::S3Object.store(
      filename,
      open(filename),
      bucket
    )
    return filename
end
