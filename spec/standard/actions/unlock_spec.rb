describe "Lock Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.import 'standard'
    @room = @plot.make Room, :name => 'a room'
    @key = @plot.make Item, :name => 'a key', :parent => @room
    @box = @plot.make Container, :name => 'a box', :parent => @room, :lock_key => @key
    @character = @plot.make Character, :name => 'a character', :parent => @room
    @key.parent = @character
  end
  it "unlocks a locked container" do
    @box.locked = true
    @character.perform :unlock, @box
    expect(@box.open?).to be(false)
    expect(@box.locked?).to be(false)
  end
end
