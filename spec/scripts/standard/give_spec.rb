describe "Give action" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/give'
    @room = @plot.make Room, :name => 'room'
    @giver = @plot.make Character, :name => 'giver', :parent => @room
    @item = @plot.make Item, :name => 'item', :parent => @giver
    @receiver = @plot.make Character, :name => 'receiver', :parent => @room
  end
  it "responds to the default syntax for give" do
    response = @giver.perform "give receiver item"
    expect(response.verb).to eq(:give)
    expect(response.arguments[0]).to eq(@receiver)
    expect(response.arguments[1]).to eq(@item)
  end
  it "responds to the extended syntax for give" do
    response = @giver.perform "give item to receiver"
    expect(response.verb).to eq(:give)
    expect(response.arguments[0]).to eq(@receiver)
    expect(response.arguments[1]).to eq(@item)
  end
end
