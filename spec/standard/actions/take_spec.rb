describe "Take Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.script 'standard'
  end
  it "takes a portable sibling" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    # Make a portable entity and take it
    entity = @plot.make Entity, :name => 'entity', :parent => room
    entity.portable = true
    character.perform 'take entity'
    expect(entity.parent).to be(character)
    # Make an item (portable by default) and take it
    item = @plot.make Item, :name => 'item', :parent => room
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "does not take a not-portable sibling" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    # Entity is not portable by default
    entity = @plot.make Entity, :name => 'entity', :parent => room
    character.perform 'take entity'
    expect(entity.parent).not_to be(character)
    # Make an item that is not portable
    item = @plot.make Item, :name => 'item', :parent => room, :portable => false
    character.perform 'take item'
    expect(item.parent).to_not be(character)
  end
  it "takes an item in an open container" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    item = @plot.make Item, :name => 'item', :parent => container
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "takes an item on a supporter" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    supporter = @plot.make Supporter, :name => 'supporter', :parent => room
    item = @plot.make Item, :name => 'item', :parent => supporter
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "takes an item from an explicit open container" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    container.open = true
    item = @plot.make Item, :name => 'item', :parent => container
    character.perform 'take item from container'
    expect(item.parent).to be(character)
  end
  it "takes multiple items" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    item1 = @plot.make Item, :name => 'one', :parent => room
    item2 = @plot.make Item, :name => 'two', :parent => room
    character.perform 'take one and two'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character)
  end
  it "detects ambiguous matches in multiple items" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    item1 = @plot.make Item, :name => 'one item', :parent => room
    item2 = @plot.make Item, :name => 'two item', :parent => room
    item3 = @plot.make Item, :name => 'three item', :parent => room
    character.perform 'take item, item, and item'
    expect(item1.parent).not_to be(character)
    expect(item2.parent).not_to be(character) 
    expect(item3.parent).not_to be(character)
  end
  it "takes all obvious items" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    item1 = @plot.make Item, :name => 'one item', :parent => room
    item2 = @plot.make Item, :name => 'two item', :parent => room
    container = @plot.make Container, :name => 'container', :parent => room
    item3 = @plot.make Item, :name => 'three item', :parent => container
    character.perform 'take all'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character) 
    expect(item3.parent).not_to be(character)    
  end
  it "takes ambiguous items for an adjectival phrase" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    item1 = @plot.make Item, :name => 'red item', :parent => room
    item2 = @plot.make Item, :name => 'red entity', :parent => room
    item3 = @plot.make Item, :name => 'blue item', :parent => room
    character.perform 'take red things'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character) 
    expect(item3.parent).not_to be(character)
    character.perform 'drop all'
    character.perform 'take things that are red'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character) 
    expect(item3.parent).not_to be(character)
  end
  it "does not take ambiguous items for a singular direct object" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    item = @plot.make Item, :name => 'ambiguous item', :parent => room
    entity = @plot.make Item, :name => 'ambiguous entity', :parent => room    
    character.perform "take ambiguous"
    expect(item.parent).not_to eq(character)
    expect(entity.parent).not_to eq(character)
  end
  it "understands exceptions" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    item1 = @plot.make Item, :name => 'red item', :parent => room
    item2 = @plot.make Item, :name => 'red entity', :parent => room
    item3 = @plot.make Item, :name => 'blue item', :parent => room
    character.perform 'take everything except the blue item'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character) 
    expect(item3.parent).not_to be(character)
    character.perform 'drop all'
    character.perform 'take things that are not blue'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character) 
    expect(item3.parent).not_to be(character)
  end
end
