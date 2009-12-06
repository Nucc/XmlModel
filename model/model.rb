module XmlModel
	class Model
		attr_reader :model
		attr_writer :production
		
        @@sources = {}
        
		def initialize (element)
        	@struct = {}
        	@struct[:options] = {}
        	@struct[:children] = []
        	@struct[:name] = String.new
			@struct[:model] = Hash.new
			@production = false
			p @production
			
        	@factory = element
        	@factory.options  = @struct[:options]
			@factory.children = @struct[:children]
			@factory.name     = @struct[:name]
			@factory.model	  = @struct[:model]
			@factory.production = @production
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
      
      	def render (destination)
			fetch
			generator = Generator.new(@struct[:model], destination)
			generator.produce
			return generator.destination.export
      	end

        def source= (source)
			@struct[:options][:source] = source.clone
        end

		def model
			@struct[:model]
		end
	
		def production= (value)
			@production = value
			@factory.production = value
		end
	
		def fetch
			@struct[:model] = @factory.fetch
			@factory.model = @struct[:model]
		end
	end
	
	class Generator
		attr_reader :destination
		
		def initialize (model, destination)
			@model = model
			@destination = destination
			read_root if @destination.destination.nil?
		end
		
		def produce
			@model.each do |key, value|				
			 	if key == "_content"
					@destination.content = value
				elsif value.class == Hash
					destination = @destination.single_element(key)
					generator = Generator.new(value, destination)
					generator.produce
					
				elsif value.class == Array
					destination = @destination.single_element(key)
					value.each do |val|
						generator = Generator.new(val, destination)
						generator.produce
					end
				else
					@destination[key] = value
				end
			end
		end
		
		def read_root
			@model.each do |key, value|
				@destination = @destination.single_element(key)
				@model = value
				return
			end
		end
	end
end