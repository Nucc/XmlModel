module XmlModel
  module Source
    
    class Base
      
      attr_reader :source
      
      def initialize(source, parent = nil)
        @source = source
        @parent = parent
      end
      
      def read(attribute)
      end
      
      def write(tag)
      end
      
    end
    
    class Xml < Base
      def read(name)
        nodes = @source.find("#{@name}")
        result = []
        nodes.each do |node|
          result << Xml.new(node, self)
        end
        return result
      end
    end
    
    class Form < Base
      
      # nevet adhassunk meg, es onnan olvassa ki rogton (tomb???)
      def initialize(source = nil, parent = nil)
        super source, parent
#        @name  = name
        @value = source["#value"] unless source.nil?
      end
      
      def read(name)
        result = []
        if @source[name].class == Array
          @source[name].each do |element|
            result << Form.new(element, self)
          end
        elsif @source[name].class == Hash
          return Form.new(@source[name], self)
        else
          return @source[name]
        end
        return result
      end
      
      def value=(value)
        @value = value
      end
      
      def value
        @value
      end
      
      def addTag(value, form)
        @tags[value] = form
      end
      
      def render
        rendered = {}
        rendered = {"#value" => @value} unless @value.nil?
        @tags ||= []
        @tags.each do |name, form|
          rendered[name] = form.render
        end
        return rendered
      end
    end
  end
  
  module Impl
    
    class Base
      attr_accessor :source
      attr_reader   :name
      
      @@evaluate_graph = []

      def initialize(*args)
        parseArguments(args)
      end
      
      def parent
        @@evaluate_graph.last
      end
      
      def parse(&blk)
      end

      def generate
      end
      
      def evaluateBlock(&blk)
        @@evaluate_graph << self
        blk.call
        afterBlockEvaluated
        @@evaluate_graph.pop
      end
      
      def parseArguments(args)
        args.flatten!
        @args = {}
        
        # Get the name of the node and convert it to String
        @name = args.shift
        @name = @name.to_s
        
        # Check the other arguments
        args.each do |arg|
          if arg.class == Hash
            arg.each do |key, value|
              @args[key.to_sym] = value
            end
          elsif arg.class == Symbol or arg.class == String
            @args[arg.to_sym] = true
          end
        end
      end
      
      def afterBlockEvaluated
      end
      
    end

    class Root < Base
      def initialize(*args, &blk)
        args = ["", args]
        @source
        super(args, blk)
      end
      
      def parseArguments(args)
        super(args)
        @source = @args[:source]
      end
      
      def parse(&blk)
        evaluateBlock(&blk)
      end
    end

    class InnerElement < Base
      
      def parse(&blk)

        # parent must be present, because we are in an InnerElement
        @sources = parent.source.find("#{@name}")
        @sources.each do |s|
          @source = s
          evaluateBlock(&blk)
        end
      end
      
      def afterBlockEvaluated
        #parent.
      end
      
    end

    class List < InnerElement
    end

    class Element < InnerElement
    end
    
    class Attribute < InnerElement
      def parse
      end
    end
    
  end
end