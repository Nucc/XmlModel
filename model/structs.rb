require 'model/model.rb'

module XmlModel
  
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

  def Option (*args, &block)
    traversal(args, Structs::Option.new, &block)
  end
  
  def Case (*args, &block)
    traversal(args, Structs::Case.new, &block)
  end

  def Attribute (*args, &block)
      traversal(args, Structs::Attribute.new, &block)
  end

protected

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

  module Structs   
       
    class Base
      attr_writer :options
      attr_writer :children
      attr_writer :name
      attr_writer :model
      attr_writer :production
          
      def generate
        @options[:destination] = @options[:destination].single_element(@name)
        @children.each do |child|
          child.render @options[:destination]
        end
      end
      
    protected
      
      def read (source, &block)
        sources = [source].flatten
        if sources.length == 0 and not @options[:nillable]
          result = {@name => {}}
          source = nil
          
          # For each child Model object
          @children.each do |child|
              
              # Set the source
            child.source = source
            
            child.production = @production
            
            child.fetch
            
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
            child.production = @production
            child.fetch
            rendered = child.model
            result[@name].merge!( rendered ) if rendered.class == Hash
            result[@name] = rendered if rendered.class == Array
          end
          yield result
        end
      end
      
      def write (destination, &block)
        @children.each do |child|
          child.render destination
        end
      end
    end

    class Root < Base
      def fetch
        if @options[:source]
            # Default path is "/@name"
          path = @options[:path] ? @options[:path] + "/#{@name}" : "/#{@name}"
          source = @options[:source]
            source.seek(path)
        end

        read source do |result|
          return result
        end
      end
    end
    
    class ListMember < Base
      def fetch
        if @options[:source]
          sources = @options[:source].multiple_element(@name)
        end

        results = []
        read sources do |result|
          results << result
        end
        return results
      end
      
      def generate
        @model.each do |element|
          destination = @options[:destination].single_element(@name)
          @children.each do |child|
            child.render destination
          end
        end
      end
    end

    class Element < Base
      def fetch
        if @options[:source]
          source = @options[:source].single_element(@name)
        end
        
        return {} if source.nil? and @options[:nillable] 
        read source do |result|
          return result
        end
      end
    end

    class List < Element
    end

    class Attribute < Base
      def fetch
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
      
      def generate
        @options[:destination][@name] = @model[@name]
      end
    end
    
    class Option < Base
      def fetch
        source = @options[:source].single_element(@name)
        model = XmlModel::Attribute(@options[:option])
        
        children = @children.clone
        @children.replace([model])
        attribute = @options[:default]

        attr_value = {}
        read source do |result|
          attr_value = result[@name][@options[:option]]
          break
        end

        @children.replace children
        ret = {}
        read source do |result|
          ret.merge! result
        end
        
        if @production == false
          ret[@name][@options[:option]] = attr_value
          return ret
        else
          ret = {@name => ret[@name][attr_value]}
          ret[@name][@options[:option]] = attr_value
          return ret
        end
      end
      
      def generate
      end
    end
    
    class Case < Base
      def fetch
        read @options[:source] do |result|
          return result
        end
      end
    end
  end
end
