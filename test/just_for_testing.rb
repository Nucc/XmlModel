
require "../init.rb"

include XmlModel

doc  = Source::Xml.open("test2.xml")
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

	Option "active", :option => 'choice', :default => "no" do
		Case "yes" do
			Element "ip_address"
		end
		
		Case "no" do
		end 
	end
end

model.source = doc
model.production = true
destination = Destination::Xml.new
a = model.render(destination)
p a



