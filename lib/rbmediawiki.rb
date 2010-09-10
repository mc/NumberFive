require 'yaml'
require 'net/http'
require 'rubygems'
require 'xmlsimple'

class Rbmediawiki
    VERSION = '0.2.6.2'
    Dir["#{File.dirname(__FILE__)}/rbmediawiki/*.rb"].sort.each { |lib| require lib }
end

