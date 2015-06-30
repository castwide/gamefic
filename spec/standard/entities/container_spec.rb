describe "Lockable Container" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.import 'standard'
    @room = @plot.make Room, :name => 'a room'
    @key = @plot.make Item, :name => 'a key', :parent => @room
    @box = @plot.make Container, :name => 'a box', :parent => @room, :key => @key
    @box.is :openable, :lockable, :closed, :locked  
    @character = @plot.make Character, :name => 'a character', :parent => @room
    @key.parent = @character
  end
  it "can be locked" do
    @box.is :locked
    @character.perform :unlock, @box
    expect(@box.is? :closed).to be(true)
  end
  it "can be unlocked" do
    @box.is :closed
    @character.perform :lock, @box
    expect(@box.is? :locked).to be(true)
  end
  it "cannot be opened when locked" do
    @box.is :locked
    @character.perform :open, @box
    expect(@box.is? :locked).to be(true)
  end
end
