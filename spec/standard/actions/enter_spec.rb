describe "Enter Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.import 'standard'
    @room = @plot.make Room, :name => 'room'
    @character = @plot.make Character, :name => 'character', :parent => @room
    @supporter = @plot.make Supporter, :name => 'supporter', :parent => @room
    @container = @plot.make Container, :name => 'container', :parent => @room
  end
  it "enters an enterable supporter" do
    @supporter.is :enterable
    @character.perform "enter supporter"
    expect(@character.parent).to eq(@supporter)
  end
  it "enters an enterable container" do
    @container.is :enterable
    @character.perform "enter container"
    expect(@character.parent).to eq(@container)
  end
  it "does not enter a not_enterable supporter" do
    @supporter.is :not_enterable
    @character.perform "enter supporter"
    expect(@character.parent).not_to eq(@supporter)
  end
  it "does not enter a not_enterable container" do
    @supporter.is :not_enterable
    @character.perform "enter supporter"
    expect(@character.parent).not_to eq(@supporter)  
  end
end
