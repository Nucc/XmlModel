module XmlModel
	module Source
		class Html
			
			def initialize (document)
				@document = document
			end
			
			def attribute (attribute)
				value = @document[attribute]
				if value.class != Array and value.class != Hash
					return @document[attribute]
				else
					# throw a warning!
					return nil
				end
			end
			
			def content
				return @document["_value"]
			end
			
			def single_element (name)
				p @document
				p name
				return Html.new( @document[name] )
			end
			
			def multiple_element (name)
				result = []
				@document.each do |value|
					result << Html.new(value)
				end
				return result
			end
		end
	end
	
	module Structs
		
		class Root
			def fetchHtml
				source = @options[:source].single_element(@name)
				_xml_read_source source do |result|
					return result
				end
			end
		end
		
		class List
			def fetchHtml
				fetchXml
			end
		end
		
		class ListMember
			def fetchHtml
				fetchXml
			end
		end
		
		class Element
			def fetchHtml
				fetchXml
			end
		end
		
		class Attribute
			def fetchHtml
				fetchXml
			end
		end
	end
end