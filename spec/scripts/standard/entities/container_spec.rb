describe "Container" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @room = @plot.make Room, :name => 'a room'
    @key = @plot.make Item, :name => 'a key', :parent => @room
    @box = @plot.make Container, :name => 'a box', :parent => @room, :lock_key => @key
    @character = @plot.make Character, :name => 'a character', :parent => @room
    @key.parent = @character
  end
  it "starts closed" do
    expect(@box.open?).to be(false)
  end
  it "starts unlocked" do
    expect(@box.locked?).to be(false)
  end
  it "closes a locked box" do
    @box.open = true
    @box.locked = true
    expect(@box.open?).to be(false)
    expect(@box.locked?).to be(true)
  end
  it "cannot be opened when locked" do
    @box.locked = true
    @character.perform :open, @box
    expect(@box.locked?).to be(true)
  end
end
