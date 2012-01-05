module Paperclip
  module Storage
    module Upyun
      def self.extended base
        base.instance_eval do
          @upyun_bucketname = @options[:upyun_bucketname]
          @upyun_username =  @options[:upyun_username]
          @upyun_password =  @options[:upyun_password]
          @upyun_domain = @options[:upyun_domain]
          @upyun_api_host = @options[:upyun_api_host] || 'http://v1.api.upyun.com/'
          
          @options[:path] = @options[:path].gsub(/:url/, @options[:url]).gsub(/^:rails_root\/public\/system/, @upyun_domain)

          @resource = RestClient::Resource.new("#{@upyun_api_host}#{@upyun_bucketname}", :user => @upyun_username, :password => @upyun_password )
        end
      end
      
        def exists?(style_name = default_style)
          if original_filename
              relative_path = path(style_name).gsub(@upyun_domain, '')
              begin
                true if @resource[relative_path].get.code == 200
              rescue RestClient::ResourceNotFound
                debugger
                false
              end
          else
            false
          end
        end


        def flush_writes #:nodoc:
          @queued_for_write.each do |style_name, file|            
            current_path = ''
            relative_path = path(style_name).gsub(@upyun_domain, '')
            path_array = relative_path.split('/')
            path_array.pop
            path_array.reject!{|p| p == ''}
            path_array.each do |p|
              current_path = current_path + p + '/'
              debugger
              @resource[current_path].post '', :folder => true
            end
            # debugger
            @resource[relative_path].post File.read(file) 
            
          end

          after_flush_writes # allows attachment to clean up temp files

          @queued_for_write = {}
        end
        
        def flush_deletes #:nodoc:
          @queued_for_delete.each do |path|
            # TODO:
          end
          @queued_for_delete = []
        end



    
    end
  end
end