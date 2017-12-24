describe "Take Action" do
  before :each do
    @plot = Plot.new(Gamefic::Plot::Source.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    # @todo Maybe move the container stuff to a separate spec file
    @plot.script 'standard/container'
  end
  it "takes a portable sibling" do
    room = @plot.make Room, :name => 'room'
    character = @plot.cast Character, :name => 'character', :parent => room
    # Make a portable entity and take it
    entity = @plot.make Thing, :name => 'entity', :parent => room
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
    character = @plot.cast Character, :name => 'character', :parent => room
    # Entity is not portable by default
    entity = @plot.make Thing, :name => 'entity', :parent => room
    character.perform 'take entity'
    expect(entity.parent).not_to be(character)
    # Make an item that is not portable
    item = @plot.make Item, :name => 'item', :parent => room, :portable => false
    character.perform 'take item'
    expect(item.parent).to_not be(character)
  end
  it "takes an item in an open container" do
    room = @plot.make Room, :name => 'room'
    character = @plot.cast Character, :name => 'character', :parent => room
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    item = @plot.make Item, :name => 'item', :parent => container
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "takes an item on a supporter" do
    room = @plot.make Room, :name => 'room'
    character = @plot.cast Character, :name => 'character', :parent => room
    supporter = @plot.make Supporter, :name => 'supporter', :parent => room
    item = @plot.make Item, :name => 'item', :parent => supporter
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "takes an item from an explicit open container" do
    room = @plot.make Room, :name => 'room'
    character = @plot.cast Character, :name => 'character', :parent => room
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    container.open = true
    item = @plot.make Item, :name => 'item', :parent => container
    character.perform 'take item from container'
    expect(item.parent).to be(character)
  end
  it "detects ambiguous matches in multiple items" do
    room = @plot.make Room, :name => 'room'
    character = @plot.cast Character, :name => 'character', :parent => room
    item1 = @plot.make Item, :name => 'one item', :parent => room
    item2 = @plot.make Item, :name => 'two item', :parent => room
    item3 = @plot.make Item, :name => 'three item', :parent => room
    character.perform 'take item, item, and item'
    expect(item1.parent).not_to be(character)
    expect(item2.parent).not_to be(character) 
    expect(item3.parent).not_to be(character)
  end
end
