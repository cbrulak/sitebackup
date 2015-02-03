require_relative 'RemoteDocument.rb'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'fileutils'

if __FILE__ == $0
  if ARGV.count < 2
    $stderr.puts "Usage: #{$0} URL DIR"
    exit 1
  end


  url = ARGV.shift
  dir = ARGV.shift
  doc = RemoteDocument.new(URI.parse(url))
  doc.mirror(dir)
end