describe "Take Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.import 'standard'
  end
  it "takes a portable sibling" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    # Make a portable entity and take it
    entity = @plot.make Entity, :name => 'entity', :parent => room
    entity.is :portable
    character.perform 'take entity'
    expect(entity.parent).to be(character)
    # Make an item (portable by default) and take it
    item = @plot.make Item, :name => 'item', :parent => room
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "does not take a not_portable sibling" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    # Entity is not portable by default
    entity = @plot.make Entity, :name => 'entity', :parent => room
    character.perform 'take entity'
    expect(entity.parent).to_not be(character)
    # Make an item that is not portable
    item = @plot.make Item, :name => 'item', :parent => room
    item.is :not_portable
    character.perform 'take item'
    expect(item.parent).to_not be(character)
  end
  it "takes an item in a container" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    container = @plot.make Container, :name => 'container', :parent => room
    item = @plot.make Item, :name => 'item', :parent => container
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "takes an item on a supporter" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    supporter = @plot.make Container, :name => 'supporter', :parent => room
    item = @plot.make Item, :name => 'item', :parent => supporter
    character.perform 'take item'
    expect(item.parent).to be(character)
  end
  it "takes an item from an explicit container" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    container = @plot.make Container, :name => 'container', :parent => room
    item = @plot.make Item, :name => 'item', :parent => container
    character.perform 'take item from container'
    expect(item.parent).to be(character)
  end
end
