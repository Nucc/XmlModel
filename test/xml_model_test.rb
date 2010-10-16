
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../'))

require 'model/structs.rb'
require 'source/xml.rb'
require 'source/html.rb'
require 'destination/xml.rb'
require 'destination/html.rb'
require 'test/unit'


class XmlModelTest < Test::Unit::TestCase

  include XmlModel

  	def setup
  	end
  
  	def test_html_source
		  source = Source::Html.new({"firmware" => {"settings" => [{"setting" => {"name" => 12, "state" => "no"}}]}})
		  xmlmodel = model()

		  xmlmodel.source = source
		  expected = {"firmware" => {"settings" => [{"setting" => {"name" => 12, "state" => "no"}}], "firewall" => {"active" => "no"}}}

		  destination = Destination::Xml.new		  
		  result = xmlmodel.render(destination)
		  assert_equal( xmlmodel.model, expected)
  	end
  
  	def test_xml_source
		  source = Source::Xml.open("test.xml")
		  model = model()
		  model.source = source
		  expected = {"firmware" =>
						  {"firewall" =>
							  {"active"=>"no"}, 
							  "settings"=> [
								  {"setting"=> {"name"=>"1", "state"=>nil}},
								  {"setting"=>{"name"=>"2", "state"=>"off"}}
							  ]
						  }
					  }
      destination = Destination::Xml.new
      result = model.render(destination)
      assert_equal( model.model, expected)

  	end
  
	def model
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
	end
end