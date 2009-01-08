require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe "Configuration" do
  it "Should read configuration" do
    i = IMAPSTORE::Imapstore.new

    i.email.should eql( 'jmca2009@gmail.com')
    i.password.should eql('masson98')
    i.store_tag.should eql('IMAPSTORE')
		i.imap_server.should eql('imap.gmail.com')
		i.imap_port.should eql(993)
  end
end

describe "Connection" do

  it "Should connect and disconnect properly" do
    i = IMAPSTORE::Imapstore.new

    i.disconnect
  end

  
end

describe "Store file" do
  
  it "Should store a file" do
    i = IMAPSTORE::Imapstore.new
    i.store_file(File.expand_path(File.dirname(__FILE__) + "/../lib/imapstore.rb"),"ttt","Test file")
    i.rm_file("ttt")
    i.disconnect    
  end
end

describe "List folder" do
  it "Sholuld list a folder" do
    i = IMAPSTORE::Imapstore.new
    i.store_file(File.expand_path(File.dirname(__FILE__) + "/../lib/imapstore.rb"),"ttt","Test file")
    i.ls("ttt").should eql(["imapstore.rb"])
    i.rm_file("ttt")
    i.disconnect    
  end
end

describe "rm_file" do
  it "Sholuld remove a file" do
    i = IMAPSTORE::Imapstore.new
    i.store_file(File.expand_path(File.dirname(__FILE__) + "/../lib/imapstore.rb"),"ttt","Test file")
    i.rm_file("ttt")
    i.ls("ttt").should eql([])
    i.disconnect    
  end
end

describe "mkdir" do
	it "should be able to create a valid folder" do
    i = IMAPSTORE::Imapstore.new
		i.mkdir('blablabla')
		
	end
end

describe "rmdir" do
	it "should be able to delete an existing folder" do
    i = IMAPSTORE::Imapstore.new
		i.mkdir('blablabla2')
		i.rmdir('blablabla2')
	end
end