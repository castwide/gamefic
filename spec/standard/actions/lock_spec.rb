describe "Lock Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.require 'standard'
    @room = @plot.make Room, :name => 'a room'
    @key = @plot.make Item, :name => 'a key', :parent => @room
    @box = @plot.make Container, :name => 'a box', :parent => @room, :lock_key => @key
    @character = @plot.make Character, :name => 'a character', :parent => @room
    @key.parent = @character
  end
  it "locks an unlocked container" do
    @box.locked = false
    @character.perform :lock, @box
    expect(@box.locked?).to be(true)
  end
end