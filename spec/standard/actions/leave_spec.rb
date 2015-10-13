describe "Leave Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.import 'standard'
    @room = @plot.make Room, :name => 'room'
    @character = @plot.make Character, :name => 'character', :parent => @room
    @supporter = @plot.make Supporter, :name => 'supporter', :parent => @room
    @receptacle = @plot.make Receptacle, :name => 'receptacle', :parent => @room
    @container = @plot.make Container, :name => 'container', :parent => @room
    @entity = @plot.make Entity, :name => 'entity', :parent => @room
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
