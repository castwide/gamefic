describe "Lock Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.script 'standard'
    @room = @plot.make Room, :name => 'a room'
    @key = @plot.make Item, :name => 'a key', :parent => @room
    @box = @plot.make Container, :name => 'a box', :parent => @room, :lock_key => @key
    @character = @plot.make Character, :name => 'a character', :parent => @room
    @key.parent = @character
  end
  it "unlocks a locked container with the key" do
    @box.locked = true
    @character.perform :unlock, @box
    expect(@box.open?).to be(false)
    expect(@box.locked?).to be(false)
  end
  it "does not unlock a locked container without the key" do
    @key.parent = nil
    @box.locked = true
    @character.perform :unlock, @box
    expect(@box.locked?).to be(true)
  end
end
