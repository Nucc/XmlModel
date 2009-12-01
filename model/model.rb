module XmlModel
	class Model
		attr_reader :model
		
        @@sources = {}
        
		def initialize (element)
        	@struct = {}
        	@struct[:options] = {}
        	@struct[:children] = []
        	@struct[:name] = String.new
        	@factory = element
        	@factory.options  = @struct[:options]
			@factory.children = @struct[:children]
			@factory.name     = @struct[:name]
			@model = {}
      	end
      
      	def [] (value)
        	Model.new( @struct[:options][value] )
      	end
      
      	def []= (key, value)
        	@struct[:options][key] = value 
      	end
      
      	def << (model)
        	@struct[:children] << model
      	end
      
      	def name= (name)
        	@struct[:name].replace name
        	@struct[:name].freeze
      	end
		
		def children ()
			@struct[:children]
		end
      
      	def render (toWhat)
      	end

        def source= (source)
			@struct[:options][:source] = source
            @model = @factory.send("fetch")
        end
	end
end