describe "Drop Action" do
  it "drops an item in the character's inventory" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.require 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item = plot.make Item, :name => 'item', :parent => character
    character.perform 'drop item'
    expect(item.parent).to eq(room)
  end
  it "drops multiple items in the character's inventory" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.require 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item1 = plot.make Item, :name => 'one', :parent => character
    item2 = plot.make Item, :name => 'two', :parent => character
    character.perform 'drop one and two'
    expect(item1.parent).to eq(room)
    expect(item2.parent).to eq(room)
  end
  it "drops all from the character's inventory" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.require 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item1 = plot.make Item, :name => 'one', :parent => character
    item2 = plot.make Item, :name => 'two', :parent => character
    character.perform 'drop all'
    expect(item1.parent).to eq(room)
    expect(item2.parent).to eq(room)    
  end
  it "drops all described" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.require 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item1 = plot.make Item, :name => 'red one', :parent => character
    item2 = plot.make Item, :name => 'red two', :parent => character
    item3 = plot.make Item, :name => 'blue one', :parent => character
    character.perform 'drop everything that is red'
    expect(item1.parent).to be(room)
    expect(item2.parent).to be(room)
    expect(item3.parent).to be(character)
  end
  it "drops all described with not" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.require 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item1 = plot.make Item, :name => 'red one', :parent => character
    item2 = plot.make Item, :name => 'red two', :parent => character
    item3 = plot.make Item, :name => 'blue one', :parent => character
    character.perform 'drop everything that is not red'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character)
    expect(item3.parent).to be(room)
  end
  it "does not execute with an unrecognized phrase" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.require 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item1 = plot.make Item, :name => 'red one', :parent => character
    item2 = plot.make Item, :name => 'red two', :parent => character
    item3 = plot.make Item, :name => 'blue one', :parent => character
    character.perform 'drop everything that is red but not a hat'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character)
    expect(item3.parent).to be(character)
  end
  it "drops all except described" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.require 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item1 = plot.make Item, :name => 'red one', :parent => character
    item2 = plot.make Item, :name => 'red two', :parent => character
    item3 = plot.make Item, :name => 'blue one', :parent => character
    character.perform 'drop everything except things that are blue'
    expect(item1.parent).to be(room)
    expect(item2.parent).to be(room)
    expect(item3.parent).to be(character)
  end
end
