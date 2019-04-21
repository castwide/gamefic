require "gamefic"

class Described
  include Gamefic::Describable
end

describe Gamefic::Describable do
  it "determines indefinite article from name" do
    d = Described.new
    d.name = "a thing"
    expect(d.name).to eq("thing")
    expect(d.indefinite_article).to eq("a")
    d.name = "an object"
    expect(d.name).to eq("object")
    expect(d.indefinite_article).to eq("an")
  end

  it "automatically uses \"the\" for definite articles" do
    d = Described.new
    d.name = "a thing"
    expect(d.definite_article).to eq("the")
    d = Described.new
    d.name = "an object"
    expect(d.definite_article).to eq("the")
  end

  it "uses correct definite and indefinite articles" do
    d = Described.new
    d.name = "a thing"
    expect(d.definitely).to eq("the thing")
    expect(d.indefinitely).to eq("a thing")
  end

  it "tries to guess indefinite articles" do
    d = Described.new
    d.name = "thing"
    expect(d.indefinite_article).to eq("a")
    d.name = "object"
    expect(d.indefinite_article).to eq("an")
  end

  it "accepts custom articles" do
    d = Described.new
    definite = "the bunch of"
    indefinite = "a bunch of"
    name = "grapes"
    d.name = name
    d.definite_article = definite
    d.indefinite_article = indefinite
    expect(d.definitely).to eq("#{definite} #{name}")
    expect(d.indefinitely).to eq("#{indefinite} #{name}")
  end

  it "ignores articles for proper names" do
    d = Described.new
    d.name = "John Smith"
    d.proper_named = true
    expect(d.definitely).to eq("John Smith")
    expect(d.indefinitely).to eq("John Smith")
    d.name = "John Doe"
    expect(d.definitely).to eq("John Doe")
    expect(d.indefinitely).to eq("John Doe")
  end

  it "recognizes proper names starting with \"The\"" do
    d = Described.new
    d.proper_named = true
    d.name = "The Thing"
    expect(d.definitely).to eq("The Thing")
    expect(d.indefinitely).to eq("The Thing")
    d.name = "The Hulk"
    expect(d.definitely).to eq("The Hulk")
    expect(d.indefinitely).to eq("The Hulk")
  end

  it "recognizes proper names starting with \"the\"" do
    d = Described.new
    d.proper_named = true
    d.name = "the Thing"
    expect(d.definitely).to eq("the Thing")
    expect(d.indefinitely).to eq("the Thing")
    d.name = "the Hulk"
    expect(d.definitely).to eq("the Hulk")
    expect(d.indefinitely).to eq("the Hulk")
  end

  it "updates names with definite articles after proper naming" do
    d = Described.new
    d.name = "the Thing"
    d.proper_named = true
    expect(d.definitely).to eq("the Thing")
  end

  it "avoids extraneous spaces for blank articles" do
    d = Described.new
    d.name = "thing"
    d.definite_article = ""
    d.indefinite_article = ""
    expect(d.definitely).to eq("thing")
    expect(d.indefinitely).to eq("thing")
  end

  it 'tracks descriptions' do
    d = Described.new
    d.name = 'thing'
    expect(d).not_to be_has_description
    text = 'a described thing'
    d.description = text
    expect(d).to be_has_description
    expect(d.description).to eq(text)
  end

  # it 'has a default description' do
  #   d = Described.new
  #   expect(d.description).to eq(Gamefic::Describable.default_description)
  # end
end
