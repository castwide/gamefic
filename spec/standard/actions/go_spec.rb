describe "Go Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.require 'standard'
  end
  it "moves the character between rooms" do
    room1 = @plot.make Room, :name => 'room one'
    room2 = @plot.make(Room, :name => 'room two')
    room2.connect room1, "south"
    character = @plot.make MetaCharacter, :name => 'character', :parent => room1
    character.perform "go north"
    expect(character.room).to be(room2)
    character.perform "go south"
    expect(character.room).to be(room1)
  end
  it "finds portals by destination" do
    room1 = @plot.make Room, :name => 'room one'
    room2 = @plot.make(Room, :name => 'room two')
    room2.connect room1, "south"
    character = @plot.make MetaCharacter, :name => 'character', :parent => room1
    character.perform "go room two"
    expect(character.room).to be(room2)
    character.perform "go room one"
    expect(character.room).to be(room1)  
  end
end
