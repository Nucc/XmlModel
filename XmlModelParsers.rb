require 'rubygems'
require 'libxml'

module XmlModel
	module Structs
		
		module Base
			def readSource (source, &block)
				sources = [source].flatten
				
				if sources.length == 0 and not @options[:nillable]
					result = {@name => {}}
					source = nil
					@children.each do |child|
						child[:source] = source
						rendered = child.render(:toXml)
						result[@name].merge!( rendered ) if rendered.class == Hash
						result[@name] = rendered if rendered.class == Array
					end
					yield result
				end
				
				sources.each do |source|
					result = {@name => {}}
					@children.each do |child|
						child[:source] = source
						rendered = child.render(:toXml)
						result[@name].merge!( rendered ) if rendered.class == Hash
						result[@name] = rendered if rendered.class == Array
					end
					yield result
				end
			end
		end
		
		class Root
			def toXml
				if @options[:source]
					path = @options[:path] || "/"
					source = XmlModel::Source::Xml.new @options[:source].find_first("#{path}/#{@name}")
				end

				readSource source do |result|
					return result
				end
			end
		end
				
		class ListMember
			def toXml
				if @options[:source]
					sources = @options[:source].multiple_element(@name)
				end
				
				results = []
				readSource sources do |result|
					results << result
				end
				return results
			end
		end
		
		class Element
			def toXml
				if @options[:source]
					source = @options[:source].single_element(@name)
				end
				
				readSource source do |result|
					return result
				end
			end
		end
		
		class List < Element
		end
		
		
		class Attribute
			def toXml
				if @options[:source]
					source = @options[:source].attribute(@name)
				end

				if not source.nil? and not @options[:nillable]
					return {@name => source}
				elsif not @options[:nillable]
					return {@name => @options[:default]}
				else
					return {}
				end
			end
		end
		
	end



	module Source
	
		class Base
			def attribute (attribute)
			end
			
			def content
			end
			
			def single_element (name)
			end
			
			def multiple_element (name)
			end
		end
	
		class Xml < Base
			
			def initialize (xml_document, base = "/")
				@document = xml_document
			end
			
			def attribute (attribute)
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
			
			protected
			
			def find(name, &block)
				@document.children.each do |child|
					if child.node_type == LibXML::XML::Node::ELEMENT_NODE and child.name = name
						yield child
					end
				end	
			end
		end
		
	end
end


	