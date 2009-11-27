require 'test/unit'

require 'XmlImpl.rb'

class XmlModelTest < Test::Unit::TestCase
  
  def setup
    @source = {"foo" => {"bar" => [{"apple" => "Alma"}, {"pear" => "Korte"}] }}
    @target = nil
  end
  
  def test_read
    base = XmlModel::Source::Form.new(@source)
    foo = base.read("foo")
    assert_equal(foo.source, {"bar" => [{"apple" => "Alma"}, {"pear" => "Korte"}] })
    bar = foo.read("bar")
    
    assert_equal(bar[0].source, {"apple" => "Alma"})
    assert_equal(bar[1].source, {"pear" => "Korte"})
    
    apple = bar[0].read("apple")
    assert_equal(apple, "Alma")

    pear = bar[1].read("pear")
    assert_equal(pear, "Korte")
  end
  
  def test_write
    child = XmlModel::Source::Form.new
    child.value = 12
    p child.render
    
    #base.addTag()
    
    #p base
  end
  
end