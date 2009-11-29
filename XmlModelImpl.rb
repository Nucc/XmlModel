module XmlModel
  
  module Engines
    class XmlReader
    end
    
    class XmlWriter
    end
    
    class HtmlParamReader
    end
    
    class HtmlParamWriter
    end
  end
  
  module Xml
    
    class Base
      attr_reader :source
      
      attr_reader :block
      attr_reader :params
      
      @@calling_stack = []

      def initialize(*args, &block)
        @block = block
        @params = args
      end

      def parse
      end
      
      def generate
      end
      
    end
    
    class Root < Base
      
      def initialize(*args, &block)
        super args, &block
      end
      
    end
    
    class Element < Base
      
      def parse(&block)
        # Get my parent
        parent = @@calling_stack.last
        @source = parent.source.find_first(@name)
        
        blo
        
        parent.parse_result = {@name => {{'_value'} => @value}}
        parent.parse_result.merge!(parse_result)
        #
        # call block
      end
      
    end
    
    class Attribute < Base
    end
    
    class List < Base
      
      @elements = []
      
      def parse
      end
      
      def source
        @elements.first
      end
    end
    
    class Option < Base
    end
  end
  
  module HtmlParam
  end
  
end