#from http://avi.io/blog/2013/12/03/upload-folder-to-s3-recursively
class S3FolderUpload
    attr_reader :folder_path, :total_files, :s3_bucket
    attr_accessor :files

    # Initialize the upload class
    #
    # folder_path - path to the folder that you want to upload
    # bucket - The bucket you want to upload to
    # aws_key - Your key generated by AWS defaults to the environemt setting AWS_KEY_ID
    # aws_secret - The secret generated by AWS
    #
    # Examples
    #   => uploader = S3FolderUpload.new("some_route/test_folder", 'your_bucket_name')
    #
    def initialize(folder_path, bucket, aws_key = ENV['AWS_KEY_ID'], aws_secret = ENV['AWS_SECRET'])
      @folder_path       = folder_path
      @files             = Dir.glob("#{folder_path}/**/*")
      @total_files       = files.length
      @connection        = AWS::S3::Base.establish_connection!(access_key_id: aws_key, secret_access_key: aws_secret)
      @s3_bucket         = bucket
    end

    # public: Upload files from the folder to S3
    #
    # thread_count - How many threads you want to use (defaults to 5)
    #
    # Examples
    #   => uploader.upload!(20)
    #     true
    #   => uploader.upload!
    #     true
    #
    # Returns true when finished the process
    def upload!(thread_count = 5)
      file_number = 0
      mutex       = Mutex.new
      threads     = []

      thread_count.times do |i|
        threads[i] = Thread.new {
          until files.empty?
            mutex.synchronize do
              file_number += 1
              Thread.current["file_number"] = file_number
            end
            file = files.pop rescue nil
            next unless file

            # I had some more manipulation here figuring out the git sha
            # For the sake of the example, we'll leave it simple
            #
            path = file

            puts "[#{Thread.current["file_number"]}/#{total_files}] uploading..."

            data = File.open(file)

            next if File.directory?(data)
            #binding.pry
            AWS::S3::S3Object.store(
              path,
              open(path),
              @s3_bucket
            )
            
            #obj = s3_bucket.objects[path]
            #obj.write(data, { acl: :public_read })
          end
        }
      end
      threads.each { |t| t.join }
    end
  end