describe "Enter Action" do
  before :each do
    @plot = Plot.new(Gamefic::Plot::Source.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/container'
    @room = @plot.make Room, :name => 'room'
    @character = @plot.cast Character, :name => 'character', :parent => @room
    @supporter = @plot.make Supporter, :name => 'supporter', :parent => @room
    @receptacle = @plot.make Receptacle, :name => 'receptacle', :parent => @room
    @container = @plot.make Container, :name => 'container', :parent => @room
    @entity = @plot.make Entity, :name => 'entity', :parent => @room
  end
  it "enters an enterable receptacle" do
    @receptacle.enterable = true
    @character.perform "enter receptacle"
    expect(@character.parent).to eq(@receptacle)
  end
  it "enters an enterable supporter" do
    @supporter.enterable = true
    @character.perform "enter supporter"
    expect(@character.parent).to eq(@supporter)
  end
  it "enters an enterable open container" do
    @container.enterable = true
    @container.open = true
    @character.perform "enter container"
    expect(@character.parent).to eq(@container)
  end
  it "does not enter an enterable closed container" do
    @container.enterable = true
    @container.open = false
    @character.perform "enter container"
    expect(@character.parent).not_to eq(@container)
  end
  it "does not enter a not-enterable receptacle" do
    @receptacle.enterable = false
    @character.perform "enter receptacle"
    expect(@character.parent).not_to eq(@receptacle)
  end
  it "does not enter a not-enterable supporter" do
    @supporter.enterable = false
    @character.perform "enter supporter"
    expect(@character.parent).not_to eq(@supporter)
  end
  it "does not enter a not-enterable container" do
    @supporter.enterable = false
    @character.perform "enter supporter"
    expect(@character.parent).not_to eq(@supporter)  
  end
end
