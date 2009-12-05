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

model.source = html
destination = Destination::Xml.new

p model.render(destination)


