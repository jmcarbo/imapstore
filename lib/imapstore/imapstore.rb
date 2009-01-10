require 'net/imap'
require 'rubygems'
require 'tmail'
require 'pp'
require 'base64'
require 'cgi'


module IMAPSTORE
	class Imapstore
		MAX_FILE_SIZE=20000000
		CHUNK_SIZE=10000000
		
		CONFIG_TEMPLATE = <<-END
email: account@gmail.com
password: password
store_tag: IMAPSTORE
imap_server: imap.gmail.com
imap_port: 993
END

    def self.create_config_file(file = File.expand_path('~/.imapstore/config.yml'))
			if !File.exists?(file)
			  puts "creating #{File.dirname(file)}"
			  FileUtils.mkdir_p(File.dirname(file))
				File.open(file,"w").write(CONFIG_TEMPLATE)
			end      
    end
    
	  def initialize
			@versioned = true
	    get_config
	    connect
	  end
	
		def versioned
			@versioned
		end
		
		def versioned=(is_versioned)
			@versioned = is_versioned
		end
		
	  def email
	    @email
	  end

	  def password
	    @password
	  end

	  def store_tag
	    @store_tag
	  end

		def imap_server
			@imap_server
		end
		
		def imap_port
			@imap_port
		end
		
	  def connect()
	    if !@imap && @email && @password && @imap_server && @imap_port
	      @imap = Net::IMAP.new(@imap_server, @imap_port, true)
	      @imap.login(@email, @password)
	    end
	  end

	  def disconnect()
	    if @imap
	      @imap.logout()
	      begin
	      	@imap.disconnect()
	      rescue 
	      end
	    end
	  end

	  def get_config(file = File.expand_path('~/.imapstore/config.yml'))
			if !File.exists?(file)
				File.open(file,"w").write(CONFIG_TEMPLATE)
			end
	    aConfig = YAML::load_file(file)

	    #COFIGURATION SECTION
	    @email = aConfig['email']
	    @password = aConfig['password']
	    @store_tag = aConfig['store_tag'] || "IMAPSTORE"
			@imap_server = aConfig['imap_server']
			@imap_port = aConfig['imap_port']
	    #END CONFIGURATION SECTION
	  end

		def store_file_chunk( file, folder = "INBOX", subject = "", chunk=nil, chunk_no=0, max_chunk_no=0 )
			if(max_chunk_no>0)
				puts "Storing part #{chunk_no} of #{max_chunk_no}"
			end
	    basename = File.basename(file)
			version = 0

			if max_chunk_no == 0
				tag = "#{@store_tag}[#{basename}]"
			else
				tag = "#{@store_tag}[#{basename}](#{chunk_no}-#{max_chunk_no})"
			end
			@imap.select(folder)
			@imap.search(["SUBJECT", tag, "NOT", "DELETED"]).each do |message_id|
				if @versioned==true
					version = version + 1
				else
					@imap.store(message_id, "+FLAGS", [:Deleted]) 
				end
			end
			@imap.expunge
			
			mail = TMail::Mail.new
	  	mail.to = @email
	  	mail.from = @email
			if max_chunk_no == 0
	  		mail.subject = "#{@store_tag}[#{basename}]"
			else
	  		mail.subject = "#{@store_tag}[#{basename}](#{chunk_no}-#{max_chunk_no})"
			end
			
			if version > 0
				mail.subject = mail.subject + "(v. #{version})"
			end
			
			if subject
				mail.subject = mail.subject + ": #{subject}"
			end
			
	  	mail.date = Time.now
	  	mail.mime_version = '1.0'

	  	mailpart1=TMail::Mail.new
	  	mailpart1.set_content_type 'text', 'plain'
	  	mailpart1.body = "This is a mail storage message of file #{file}"	
	  	mail.parts << mailpart1
	  	mail.set_content_type 'multipart', 'mixed'

	  	if FileTest.exists?(file)
	  		mailpart=TMail::Mail.new
	  		mailpart.body = Base64.encode64(chunk.to_s)
	  		mailpart.transfer_encoding="Base64"
				if max_chunk_no == 0
	  			mailpart['Content-Disposition'] = "attachment; filename=#{CGI::escape(basename)}"
				else
	  			mailpart['Content-Disposition'] = "attachment; filename=#{CGI::escape(basename)}_#{chunk_no}-#{max_chunk_no}"
				end
	  		mail.parts.push(mailpart)
	  	end


	  	@imap.append(folder, mail.to_s, [:Seen], File.new(file).atime)

		end
		
	  def store_file( file, folder = "INBOX", subject = "")

	  	@imap.create(folder) if !@imap.list("", folder)

			size = File.size(file) 
			if(size > MAX_FILE_SIZE)
				remaining = size
				max_chunk_no = (size/CHUNK_SIZE)+1
				chunk_no = 1
				File.open(file) do |f|
					while(remaining>0)
						content = f.read(CHUNK_SIZE)
						store_file_chunk( file, folder, subject, content, chunk_no, max_chunk_no)
						chunk_no = chunk_no +1
						remaining = remaining - CHUNK_SIZE
					end
				end
			else
				content=File.open(file).read
				store_file_chunk( file, folder, subject, content)
			end
	  end
	
		def transverse(target_folder = "INBOX", glob = /.+/, recursive = false, dot_files = false, folder_only=false)
		  file_list=[]

			@imap.list(target_folder, "*").each do |folder|
				if ((recursive == true) && (folder.name.match(/^#{target_folder}(\/.+)*$/))) || (folder.name == target_folder) 
					file_list << folder.name
					yield(folder.name, nil, nil, nil, nil) if block_given?
					
					if((!folder.attr.include? :Noselect) && (folder_only==false))

				    @imap.select(folder.name)

				    @imap.search(["NOT", "DELETED"]).each do |message_id|
				      a = @imap.fetch(message_id, "RFC822")
				      mail = TMail::Mail.parse(a[0].attr["RFC822"])
				      file_name = mail.subject.match(/^[^\[]+\[([^\]]+)\]/)[1]
				      file_list << folder.name + "/" + file_name if file_name.match(glob)
							yield(folder.name, file_name, message_id, mail, file_name) if block_given? && file_name.match(glob)
						end
					end
				end
			end

	    file_list.sort			
		end

	  def ls(target_folder = "INBOX", glob = /.+/, recursive = false, dot_files = false)
			transverse(target_folder, glob, recursive, dot_files, false)
	  end

	  def get_file(target_folder = "INBOX", glob = /.+/, recursive = false, dot_files = false)
			file_list = transverse(target_folder, glob, recursive, dot_files, false) do |folder, file, message_id, mail, file_name|
				
				if mail && mail.multipart? then
				    mail.parts.each do |m|
				      if !m.main_type
								append_dir = folder.sub(/^#{target_folder}\/*/,"")
								if append_dir != ""
									Dir.mkdir(append_dir) if !File.exists? append_dir

									file_name = append_dir + "/" + file_name
								end
								File.open(file_name,"w").write(m.body)
							end
				    end
				end
			end
	  end



	  def rm_file(folder = "INBOX", glob = /.+/, recursive = false, dot_files = false)
			file_list = transverse(target_folder, glob, recursive, dot_files, false) do |folder, file, message_id, mail, file_name|
	      @imap.store(message_id, "+FLAGS", [:Deleted]) if file && message_id
			end
			
	    @imap.expunge

	    file_list
	  end

		def mkdir(folder)
			@imap.create(folder)
		end
		
		def rmdir(folder, recursive = false, dot_files = false)
			transverse(target_folder, glob, false, dot_files, true) do |folder, file, message_id, mail, file_name|
				rm_file(folder)
				@imap.delete(folder)
			end
		end
		
		def quota(folder)
			@imap.getquotaroot(folder)
		end
	end
end