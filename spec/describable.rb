require "gamefic"
include Gamefic

class Described
  include Describable
end

describe Describable do
  it "determines indefinite article from name" do
    d = Described.new
    d.name = "a thing"
    d.name.should eq("thing")
    d.indefinite_article.should eq("a")
    d.name = "an object"
    d.name.should eq("object")
    d.indefinite_article.should eq("an")
  end
  it "automatically uses \"the\" for definite articles" do
    d = Described.new
    d.name = "a thing"
    d.definite_article.should eq("the")
    d = Described.new
    d.name = "an object"
    d.definite_article.should eq("the")
  end
  it "uses correct definite and indefinite articles" do
    d = Described.new
    d.name = "a thing"
    d.definitely.should eq("the thing")
    d.indefinitely.should eq("a thing")
  end
  it "ignores articles for proper names" do
    d = Described.new
    d.name = "John Smith"
    d.proper_named = true
    d.definitely.should eq("John Smith")
    d.indefinitely.should eq("John Smith")
    d.name = "John Doe"
    d.definitely.should eq("John Doe")
    d.indefinitely.should eq("John Doe")
  end
  it "recognizes proper names starting with \"The\"" do
    d = Described.new
    d.proper_named = true
    d.name = "The Thing"
    d.definitely.should eq("The Thing")
    d.indefinitely.should eq("The Thing")
    d.name = "The Hulk"
    d.definitely.should eq("The Hulk")
    d.indefinitely.should eq("The Hulk")
  end
  it "recognizes proper names starting with \"the\"" do
    d = Described.new
    d.proper_named = true
    d.name = "the Thing"
    d.definitely.should eq("the Thing")
    d.indefinitely.should eq("the Thing")
    d.name = "the Hulk"
    d.definitely.should eq("the Hulk")
    d.indefinitely.should eq("the Hulk")
  end
end
