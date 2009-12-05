require 'rubygems'
require 'destination/abstract.rb'
require 'libxml'

module XmlModel
	module Destination
		class Xml
			include Interface
			attr :destination

			def initialize (destination = nil)
				self.destination = destination
			end
			
			def destination= (destination)
				@destination = destination
			end

			def single_element (name)
				node = LibXML::XML::Node.new name
				@destination << node unless @destination.nil?
				return Xml.new(node)
			end

			def content= (value)
				@destination.content = value
			end

			def []= (name, value)
				@destination[name] = value.to_s
			end
			
			def export
				return @destination
			end
		end
	end
end