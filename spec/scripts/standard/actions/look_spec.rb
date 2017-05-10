describe "Look Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
  end
  it "responds to looking at siblings" do
    room = @plot.make Room, :name => 'room'
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => room
    character = @plot.make Character, :name => 'character', :parent => room
    character.connect User::Base.new
    character.perform 'look item'
    expect(character.messages).to include(item.description)
  end
  it "responds to looking at an entity in a sibling container" do
    room = @plot.make Room, :name => 'room'
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => container
    character = @plot.make Character, :name => 'character', :parent => room
    character.connect User::Base.new
    character.perform 'look item'
    expect(character.messages).to include(item.description)
  end
  it "responds to looking at an entity in a sibling supporter" do
    room = @plot.make Room, :name => 'room'
    supporter = @plot.make Supporter, :name => 'supporter', :parent => room
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => supporter
    character = @plot.make Character, :name => 'character', :parent => room
    character.connect User::Base.new
    character.perform 'look item'
    expect(character.messages).to include(item.description)
  end
  it "responds to looking at an entity attached to a sibling" do
    room = @plot.make Room, :name => 'room'
    fixture = @plot.make Fixture, :name => 'supporter', :parent => room
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => fixture
    item.attached = true
    character = @plot.make Character, :name => 'character', :parent => room
    character.connect User::Base.new
    character.perform 'look item'
    expect(character.messages).to include(item.description)
  end
  it "responds to looking at an entity in an explicit open container" do
    room = @plot.make Room, :name => 'room'
    container = @plot.make Container, :name => 'container', :parent => room, :open => true
    item = @plot.make Item, :name => 'item', :description => 'The item description.', :parent => container
    character = @plot.make Character, :name => 'character', :parent => room
    character.connect User::Base.new
    character.perform 'look at item in container'
    expect(character.messages).to include(item.description)
  end
end
