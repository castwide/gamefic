describe "Clothing" do
  before :each do
    @plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    @plot.script 'standard'
    @plot.script 'standard/clothing'
  end
  it "attaches to character when worn" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make Character, :name => 'character', :parent => room
    clothing = @plot.make Clothing, :name => 'clothing', :parent => character
    #expect(@item.parent).to be(@character)
    expect(clothing.attached?).to be(false)
    character.perform "wear clothing"
    expect(clothing.attached?).to be(true)
    character.perform "take off clothing"
    expect(clothing.attached?).to be(false)
  end
  it "limits worn clothing to one per class" do
    room = @plot.make Room, :name => 'room'
    character = @plot.make Character, :name => 'character', :parent => room
    red_coat = @plot.make Coat, :name => 'red coat', :parent => character
    blue_coat = @plot.make Coat, :name => 'blue coat', :parent => character
    character.perform "wear red coat"
    expect(red_coat.attached?).to be(true)
    character.perform "wear blue coat"
    expect(blue_coat.attached?).to be(false)
  end
end
