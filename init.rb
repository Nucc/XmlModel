$LOAD_PATH << File.dirname(__FILE__)

=begin
require 'model/structs.rb'
require 'source/xml.rb'
require 'source/html.rb'

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

model.source = doc
p model.model
=end