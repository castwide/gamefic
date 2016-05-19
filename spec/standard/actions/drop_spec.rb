describe "Drop Action" do
  it "drops an item in the character's inventory" do
    plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.script 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    item = plot.make Item, :name => 'item', :parent => character
    character.perform 'drop item'
    expect(item.parent).to eq(room)
  end
end
