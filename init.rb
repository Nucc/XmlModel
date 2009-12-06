$LOAD_PATH << File.dirname(__FILE__)

require 'model/structs.rb'
require 'source/xml.rb'
require 'source/html.rb'
require 'destination/xml.rb'
require 'destination/html.rb'

include XmlModel

doc  = Source::Xml.open("test.xml")
html = Source::Html.new({"firmware" => {"settings" => [{"setting" => {"name" => 12, "state" => "no"}}]}})

model = 
Root "firmware" do
	List "settings" do
    	ListMember "setting" do
      		Attribute "name"
      		Attribute "state"
    	end
  	end

  	Element "firewall", :nillable do
		Attribute "active"
  	end

	Option "optiona", :option => 'choice', :default => "no" do
		Case "yes" do
			Element "kortefa"
		end
		
		Case "no" do
			Element "almafa"
		end 
	end
end

model.source = doc
model.production = true
destination = Destination::Xml.new
a = model.render(destination)
p a


