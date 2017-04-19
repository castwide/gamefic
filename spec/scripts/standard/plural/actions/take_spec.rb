describe "Plural Take Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/plural'
  end
  it "takes multiple items" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make Character, :name => 'character', :parent => room
    item1 = @plot.make Item, :name => 'one', :parent => room
    item2 = @plot.make Item, :name => 'two', :parent => room
    character.perform 'take one and two'
    expect(item1.parent).to be(character)
    expect(item2.parent).to be(character)
  end
  it "takes all obvious items" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make Character, :name => 'character', :parent => room
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
    character = @plot.make Character, :name => 'character', :parent => room
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
    character = @plot.make Character, :name => 'character', :parent => room
    item = @plot.make Item, :name => 'ambiguous item', :parent => room
    entity = @plot.make Item, :name => 'ambiguous entity', :parent => room    
    character.perform "take ambiguous"
    expect(item.parent).not_to eq(character)
    expect(entity.parent).not_to eq(character)
  end
  it "understands exceptions" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make Character, :name => 'character', :parent => room
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
