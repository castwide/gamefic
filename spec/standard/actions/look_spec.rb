describe "Look Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.script 'standard'
  end
  it "responds to looking at siblings" do
    room = @plot.make Room, :name => 'room'
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => room
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    character.perform 'look item'
    expect(character.output[0]).to eq(item.description)
  end
  it "responds to looking at an entity in a sibling container" do
    room = @plot.make Room, :name => 'room'
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => container
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    character.perform 'look item'
    expect(character.output[0]).to eq(item.description)
  end
  it "responds to looking at an entity in a sibling supporter" do
    room = @plot.make Room, :name => 'room'
    supporter = @plot.make Supporter, :name => 'supporter', :parent => room
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => supporter
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    character.perform 'look item'
    expect(character.output[0]).to eq(item.description)
  end
  it "responds to looking at an entity attached to a sibling" do
    room = @plot.make Room, :name => 'room'
    fixture = @plot.make Fixture, :name => 'supporter', :parent => room
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => fixture
    item.attached = true
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    character.perform 'look item'
    expect(character.output[0]).to eq(item.description)
  end
  it "responds to looking at an entity in an explicit open container" do
    room = @plot.make Room, :name => 'room'
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => container
    character = @plot.make MetaCharacter, :name => 'character', :parent => room
    character.perform 'look at item in container'
    expect(character.output[0]).to eq(item.description)
  end
end
