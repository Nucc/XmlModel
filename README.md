XmlModel
========

The goal of the project is the Rails framework be able to use XML files as model. This project is very at the beginning, so currently it's not usable in production.

I would give you a short description about my idea:

We have different sources which can be file or array of hashes:
<pre>
doc  = Source::Xml.open("test.xml")
html = Source::Html.new( {"firmware" =>
                            {"settings" =>
                              [ {"setting" =>
                                  {"name" => 12,
                                   "state" => "no"
                                  }
                                }
                              ]
                            }
                          })
</pre>

<code>Xml.open</code> loads a config or other xml file that stores information in xml format, and Html.new is useful when the browser sends the form data back to the server and it need to create new xml file from this data.

Each xml file has a specified schema, that needs to be valid after loading a file or saving an xml. The schema looks like this:

<pre>
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
</pre>

This schema defines a firmware root node. The firmware has many settings and a setting node must have a name and a state attribute. Each element or attribute that doesn't have <code>:nillable</code> keyword must be defined. The firewall node is :nillable, so it can be missing and if the firewall node's value in the source is nil, then it won't be present in the generated Xml tree. In that case firewall node was not empty, it must have an active attribute.
Options can define conditions in the xml. The subtree can be different according to an attribute of a node. So the subtree of the active node in the example can be empty when the "choice" attribute is "no", and it must contain an ip_address element when the "choice" is "yes".


test.xml
--------

<pre>
&lt;firmware&gt;
  &lt;settings&gt;
    &lt;setting name="1"&gt;&lt;/setting&gt;
    &lt;setting name="2" state="off"&gt;&lt;/setting&gt;
  &lt;/settings&gt;

  &lt;firewall active="no"/&gt;

  &lt;active choice="yes"&gt;
    &lt;ip_address&gt;192.168.1.1&lt;/ip_address&gt;
  &lt;/active&gt;
&lt;/firmware&gt;
</pre>

mymodel.rb
----------

<pre>
doc = Source::Xml.open("test.xml")

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
</pre>

<li>Defining the source of the model (currently this is the test.xml)</li>
<pre>
model.source = doc
</pre>

<li>We should generate an xml that valid for the model</li>

<b>Note:</b> it clears those elements # which don't valid as the model!

<pre>
destination = Destination::Xml.new
result = model.render(destination)
</pre>