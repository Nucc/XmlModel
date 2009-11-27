require 'rubygems'
require 'XmlImpl.rb'
require 'libxml'

module XmlModel

  class Document
    include LibXML::XML
    
    attr_accessor :root
    
    def initialize(document)
      @doc = ::LibXML::XML::Document.file(document)
      @root = @doc
    end

    def root=(root)
      @root = @doc.find_first(root)
    end
  end

  def Root(*args, &blk)
    node = Impl::Root.new(args)
    node.parse(&blk)
  end
  
  def Element(*args, &blk)
    node = Impl::Element.new(args)
    node.parse(&blk)
  end
  
  def List(*args, &blk)
    node = Impl::List.new(args)
    node.parse(&blk)
  end

  def Attribute(*args, &blk)
    node = Impl::Attribute.new(*args)
    node.parse(&blk)
  end

end


include XmlModel

doc = XmlModel::Document.new("test.xml")
doc.root = "/config/firewall"

Root :source => doc.root do 
  List :settings do 
    Element :setting, :nillable, :default => 'almafa' do
      Attribute :id, :default => "12"
      Attribute :name
    end
  end
  
  List :options do
    Element :option do
      Attribute :id, :default => "123"
    end
  end
end

a = {"asd" => {"bsd" => "aa"}}
f= XmlModel::Source::Form.new(a)
p f
g = f.read("asd")
p g
p g.read("bsd")