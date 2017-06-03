describe "Lock Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/container'
    @room = @plot.make Room, :name => 'a room'
    @key = @plot.make Item, :name => 'a key', :parent => @room
    @box = @plot.make Container, :name => 'a box', :parent => @room, :lock_key => @key
    @character = @plot.cast Character, :name => 'a character', :parent => @room
    @key.parent = @character
  end
  it "locks an unlocked container" do
    @box.locked = false
    @character.perform :lock, @box, @key
    expect(@box.locked?).to be(true)
  end
end

describe "Unlock Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/container'
    @room = @plot.make Room, :name => 'a room'
    @key = @plot.make Item, :name => 'a key', :parent => @room
    @box = @plot.make Container, :name => 'a box', :parent => @room, :lock_key => @key
    @box.locked = true
    @character = @plot.cast Character, :name => 'a character', :parent => @room
    @key.parent = @character
  end
  it "unlocks a locked container with the key" do
    @character.perform :unlock, @box, @key
    expect(@box.open?).to be(false)
    expect(@box.locked?).to be(false)
  end
  it "does not unlock a locked container without the key" do
    @character.perform :unlock, @box
    expect(@box.locked?).to be(true)
  end
end

describe "Open Action" do
  it "opens a closed container" do
    plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    plot.script 'standard/container'
    room = plot.make Room, :name => 'room'
    container = plot.make Container, :name => 'container', :parent => room
    container.open = false
    character = plot.cast Character, :name => 'character', :parent => room
    character.perform "open container"
    expect(container.open?).to eq(true)
  end
  it "does not open a locked container" do
    plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    room = plot.make Room, :name => 'room'
    container = plot.make Container, :name => 'container', :parent => room
    container.open = false
    container.locked = true
    character = plot.cast Character, :name => 'character', :parent => room
    character.perform "open container"
    expect(container.open?).to eq(false)
  end
end

describe "Close Action" do
  it "closes an open container" do
    plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    plot.script 'standard/container'
    room = plot.make Room, :name => 'room'
    container = plot.make Container, :name => 'container', :parent => room
    container.open = true
    character = plot.cast Character, :name => 'character', :parent => room
    character.perform "close container"
    expect(container.open?).to eq(false)
  end
end
