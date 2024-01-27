# frozen_string_literal: true

describe Gamefic::Describable do
  let(:described) do
    Object.new.tap { |obj| obj.extend Gamefic::Describable }
  end

  it "determines indefinite article from name" do
    described.name = "a thing"
    expect(described.name).to eq("thing")
    expect(described.indefinite_article).to eq("a")
    described.name = "an object"
    expect(described.name).to eq("object")
    expect(described.indefinite_article).to eq("an")
  end

  it "automatically uses \"the\" for definite articles" do
    described.name = "a thing"
    expect(described.definite_article).to eq("the")
    described.name = "an object"
    expect(described.definite_article).to eq("the")
  end

  it "uses correct definite and indefinite articles" do
    described.name = "a thing"
    expect(described.definitely).to eq("the thing")
    expect(described.indefinitely).to eq("a thing")
  end

  it "tries to guess indefinite articles" do
    described.name = "thing"
    expect(described.indefinite_article).to eq("a")
    described.name = "object"
    expect(described.indefinite_article).to eq("an")
  end

  it "accepts custom articles" do
    definite = "the bunch of"
    indefinite = "a bunch of"
    name = "grapes"
    described.name = name
    described.definite_article = definite
    described.indefinite_article = indefinite
    expect(described.definitely).to eq("#{definite} #{name}")
    expect(described.indefinitely).to eq("#{indefinite} #{name}")
  end

  it "ignores articles for proper names" do
    described.name = "John Smith"
    described.proper_named = true
    expect(described.definitely).to eq("John Smith")
    expect(described.indefinitely).to eq("John Smith")
    described.name = "John Doe"
    expect(described.definitely).to eq("John Doe")
    expect(described.indefinitely).to eq("John Doe")
  end

  it "recognizes proper names starting with \"The\"" do
    described.proper_named = true
    described.name = "The Thing"
    expect(described.definitely).to eq("The Thing")
    expect(described.indefinitely).to eq("The Thing")
    described.name = "The Hulk"
    expect(described.definitely).to eq("The Hulk")
    expect(described.indefinitely).to eq("The Hulk")
  end

  it "recognizes proper names starting with \"the\"" do
    described.proper_named = true
    described.name = "the Thing"
    expect(described.definitely).to eq("the Thing")
    expect(described.indefinitely).to eq("the Thing")
    described.name = "the Hulk"
    expect(described.definitely).to eq("the Hulk")
    expect(described.indefinitely).to eq("the Hulk")
  end

  it "updates names with definite articles after proper naming" do
    described.name = "the Thing"
    described.proper_named = true
    expect(described.definitely).to eq("the Thing")
  end

  it "avoids extraneous spaces for blank articles" do
    described.name = "thing"
    described.definite_article = ""
    described.indefinite_article = ""
    expect(described.definitely).to eq("thing")
    expect(described.indefinitely).to eq("thing")
  end

  it 'tracks descriptions' do
    described.name = 'thing'
    expect(described).not_to be_has_description
    text = 'a described thing'
    described.description = text
    expect(described).to be_has_description
    expect(described.description).to eq(text)
  end

  it 'has a default description' do
    described.name = 'thing'
    expect(described.description).to eq(Gamefic::Describable.default_description % {name: 'the thing', Name: 'The thing'})
  end
end
