$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'imapstore/imapstore.rb'

module IMAPSTORE
  VERSION = '0.4.7'

end