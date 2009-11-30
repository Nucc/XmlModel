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
				return Html.new( @document[name] ) if @document[name]
				return nil
			end
			
			def multiple_element (name)
				result = []
				@document.each do |value|
					result << Html.new(value[name]) if value[name]
				end
				return result
			end
			
			def seek (path)
			    path.split("/").each do |p|
			        @document = @document[p] if p != ""
			    end
		    end
		end
	end
end