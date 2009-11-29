require "XmlModelParsers.rb"

module XmlModel
  
	class Model
		
		def initialize (element)
        	@struct = {}
        	@struct[:options] = {}
        	@struct[:children] = []
        	@factory = element
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
        	@struct[:name] = name
      	end
		
		def children ()
			@struct[:children]
		end
      
      	def render (toWhat)
			@factory.options  = @struct[:options]
			@factory.children = @struct[:children]
			@factory.name     = @struct[:name]
        	@factory.send toWhat
      	end

	end
  
    @@evaluate_stack = []
  
	def traversal (args, object, &block)

    	model = Model.new(object)
      	model.name = args.shift

      	args.flatten.each do |arg|
        	if arg.class == String
          		arg = arg.to_sym
        	end

        	if arg.class == Symbol
          		model[arg] = true
        	elsif arg.class == Hash
          		arg.each do |key, param|
            		model[key] = param
          		end
        	end
      	end
      
      	if block
        	@@evaluate_stack << model
	        block.call
	        @@evaluate_stack.pop
		end
      	@@evaluate_stack.last << model if @@evaluate_stack.length > 0
      	return model
	end
    
    def Root (*args, &block)
    	traversal(args, Structs::Root.new, &block)
    end
    
    def Element (*args, &block)
      	traversal(args, Structs::Element.new, &block)
    end
    
    def List (*args, &block)
      	traversal(args, Structs::List.new, &block)
    end
    
	def ListMember (*args, &block)
      	traversal(args, Structs::ListMember.new, &block)
    end

    def Attribute (*args, &block)
      	traversal(args, Structs::Attribute.new, &block)
    end


    module Structs
		module Base
			attr_writer :options
			attr_writer :children
			attr_writer :name
		end

      	class Root
			include Base
      	end
      
      	class Element
			include Base
      	end
      
      	class List
			include Base
      	end

      	class ListMember
			include Base
      	end
      
      	class Attribute
			include Base
      	end
	end
end

include XmlModel


doc = LibXML::XML::Document.file("test.xml")

model = 
Root "firmware", :nillable, :source => doc do
	List "settings" do
    	ListMember "setting", :nillable do
      		Attribute "name", :nillable
      		Attribute "state", :nillable
    	end
  	end

  	Element "firewall" do
		Attribute "active"
  	end
end

p (model.render :toXml)