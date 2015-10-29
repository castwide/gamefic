describe "Ambiguousness" do
  before :each do
    @plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    @plot.require 'standard'
    @room = @plot.make Room, :name => 'room'
    @character = @plot.make Character, :name => 'character', :parent => @room
    @item = @plot.make Item, :name => 'red item', :parent => @room
    @entity = @plot.make Entity, :name => 'red entity', :parent => @room
  end
  it "does not take an ambiguous item" do
    @character.perform "take red"
    expect(@item.parent).not_to eq(@character)
  end
end
