require 'rubygems'
require 'source/abstract.rb'
require 'libxml'

module XmlModel
	module Source
		class Xml
		    include Interface
	
			def self.open (file)
			    return Xml.new(LibXML::XML::Document.file(file))
		    end
	
			def attribute (attribute)
			  p "aa"
				@document.attributes[attribute]
			end
	
			def content
				self.new @document.content
			end
	
			def single_element (name)
				find name do |child|
					return Xml.new(child)
				end
			end
	
			def multiple_element (name)
				result = []
				find name do |child|
					result << Xml.new(child)
				end
				return result
			end
	
			def seek (path)
			    @document = @document.find_first(path)
		    end
	
		protected
	
			def find (name, &block)
				@document.children.each do |child|
					if child.node_type == LibXML::XML::Node::ELEMENT_NODE and child.name == name
						yield child
					end
				end	
			end
		end
	end
end