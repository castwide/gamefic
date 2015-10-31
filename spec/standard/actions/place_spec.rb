describe "Place Action" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.require 'standard'
    @room = @plot.make Room, :name => 'room'
    @character = @plot.make Character, :name => 'character', :parent => @room
    @item = @plot.make Item, :name => 'item', :parent => @character
    @thing = @plot.make Item, :name => 'thing', :parent => @character
    @receptacle = @plot.make Receptacle, :name => 'receptacle', :parent => @room
    @container = @plot.make Container, :name => 'container', :parent => @room
    @supporter = @plot.make Supporter, :name => 'supporter', :parent => @room
    @entity = @plot.make Entity, :name => 'entity', :parent => @room
  end
  it "places an item on a supporter" do
    @character.perform "place item on supporter"
    expect(@item.parent).to eq(@supporter)
  end
  it "places an item in a receptacle" do
    @character.perform "place item in receptacle"
    expect(@item.parent).to eq(@receptacle)
  end
  it "places an item in an open container" do
    @container.open = true
    @character.perform "place item in container"
    expect(@item.parent).to eq(@container)
  end
  it "does not place an item in a closed container" do
    @container.open = false
    @character.perform "place item in container"
    expect(@item.parent).to eq(@character)
  end
  it "does not place an item on a generic entity" do
    @character.perform 'place item on entity'
    expect(@item.parent).to be(@character)
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
