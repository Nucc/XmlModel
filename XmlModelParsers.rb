require 'rubygems'
require 'libxml'

module XmlModel
	
	module Source
	
		module Interface
			def attribute (attribute)
			end
			
			def content
			end
			
			def single_element (name)
			end
			
			def multiple_element (name)
			end
		end
	
		class Xml
		    include Interface
			
			def self.open (file)
			    return Xml.new(LibXML::XML::Document.file(file))
		    end
			
			def initialize (xml_document)
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
			
			def seek (path)
			    @document = @document.find_first(path)
		    end
			
			protected
			
			def find(name, &block)
				@document.children.each do |child|
					if child.node_type == LibXML::XML::Node::ELEMENT_NODE and child.name == name
						yield child
					end
				end	
			end
		end
	end

	module Structs
	    
		module Base
			def _xml_read_source (source, &block)
				sources = [source].flatten
		
				if sources.length == 0 and not @options[:nillable]
					result = {@name => {}}
					source = nil
					
					# For each child Model object
					@children.each do |child|
					    
					    # Set the source
						child.source = source
						
						# Fetch the generated model structure
						rendered = child.model
						
						# And merge with the current model's structure
						result[@name].merge!( rendered ) if rendered.class == Hash
						result[@name] = rendered if rendered.class == Array
					end
					yield result
				end
		
				sources.each do |source|
					result = {@name => {}}
					@children.each do |child|
						child.source = source
						rendered = child.model
						result[@name].merge!( rendered ) if rendered.class == Hash
						result[@name] = rendered if rendered.class == Array
					end
					yield result
				end
			end
		end

		class Root
			def fetchXml
				if @options[:source]
				    # Default path is "/@name"
					path = @options[:path] ? @options[:path] + "/#{@name}" : "/#{@name}"
					source = @options[:source]
				    source.seek(path)
				end

				_xml_read_source source do |result|
					return result
				end
			end
		end
		
		class ListMember
			def fetchXml
				if @options[:source]
					sources = @options[:source].multiple_element(@name)
				end
		
				results = []
				_xml_read_source sources do |result|
					results << result
				end
				return results
			end
		end

		class Element
			def fetchXml
				if @options[:source]
					source = @options[:source].single_element(@name)
				end
		
				_xml_read_source source do |result|
					return result
				end
			end
		end

        # TODO: valahogy osszehozni az Element::fetchXml metodussal
		class List
		    def fetchXml
				if @options[:source]
					source = @options[:source].single_element(@name)
				end
		
				_xml_read_source source do |result|
					return result
				end
			end
		end


		class Attribute
			def fetchXml
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



end


	