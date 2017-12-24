describe "Leave Action" do
  before :each do
    @plot = Plot.new(Gamefic::Plot::Source.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/container'
    @room = @plot.make Room, :name => 'room'
    @character = @plot.cast Character, :name => 'character', :parent => @room
    @supporter = @plot.make Supporter, :name => 'supporter', :parent => @room, :enterable => true
    @receptacle = @plot.make Receptacle, :name => 'receptacle', :parent => @room, :enterable => true
    @container = @plot.make Container, :name => 'container', :parent => @room, :enterable => true
    @entity = @plot.make Entity, name: 'entity', parent: @room
  end
  it "leaves a supporter" do
    @character.parent = @supporter
    @character.perform "leave supporter"
    expect(@character.parent).to eq(@room)
  end
  it "leaves a receptacle" do
    @character.parent = @receptacle
    @character.perform "leave receptacle"
    expect(@character.parent).to eq(@room)
  end
  it "leaves an open container" do
    @character.parent = @container
    @container.open = true
    @character.perform "leave container"
    expect(@character.parent).to eq(@room)
  end
  it "does not leave a closed container" do
    @character.parent = @container
    @container.open = false
    @character.perform "leave container"
    expect(@character.parent).to eq(@container)
  end
end
