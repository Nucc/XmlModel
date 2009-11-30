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
            method = source.class.to_s.split("::").last
            
            # if the class name is Xml, we call fetchXml method to generate 
            # model structure
            @model = @factory.send("fetch#{method}")
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

# it will be a Model file somewhere in the app
require "XmlModelParsers.rb"
include XmlModel

doc = LibXML::XML::Document.file("test.xml")

doc = Source::Xml.open("test.xml")

model = 
Root "firmware", :nillable do
	List "settings" do
    	ListMember "setting" do
      		Attribute "name"
      		Attribute "state"
    	end
  	end

  	Element "firewall" do
		Attribute "active"
  	end
end

model.source = doc
p model.model
#p model