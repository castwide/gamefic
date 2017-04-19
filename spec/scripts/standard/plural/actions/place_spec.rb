describe "Plural Place Action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/plural'
    @room = @plot.make Room, :name => 'room'
    @character = @plot.make Character, :name => 'character', :parent => @room
    @item = @plot.make Item, :name => 'item', :parent => @character
    @thing = @plot.make Item, :name => 'thing', :parent => @character
    @receptacle = @plot.make Receptacle, :name => 'receptacle', :parent => @room
    @container = @plot.make Container, :name => 'container', :parent => @room
    @supporter = @plot.make Supporter, :name => 'supporter', :parent => @room
    @entity = @plot.make Entity, :name => 'entity', :parent => @room
  end
  it "places all on a supporter" do
    @character.perform 'put all on supporter'
    expect(@item.parent).to be(@supporter)
    expect(@thing.parent).to be(@supporter)
  end
  it "places all described on a supporter" do
    @character.perform 'put all things on supporter'
    expect(@item.parent).to be(@character)
    expect(@thing.parent).to be(@supporter)
  end
  it "places all not described on a supporter" do
    @character.perform 'put all not things on supporter'
    expect(@item.parent).to be(@supporter)
    expect(@thing.parent).to be(@character)
  end
  it "places plurals on a supporter" do
    @character.perform 'put things on supporter'
    expect(@item.parent).to be(@character)
    expect(@thing.parent).to be(@supporter)
  end
  it "places all except described on a supporter" do
    @character.perform 'put all except thing on supporter'
    expect(@item.parent).to be(@supporter)
    expect(@thing.parent).to be(@character)
  end
end
