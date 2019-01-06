require 'securerandom'

describe "Inventory Action" do
  it "lists an item in a character's inventory" do
    plot = Gamefic::Plot.new(Gamefic::Plot::Source.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    # TODO: We need to put the character in a room so the has-enough-light room won't cause an error
    room = plot.make Room, :name => 'room'
    character = plot.cast Character, :name => 'character', :parent => room
    item_name = SecureRandom.hex
    item = plot.make Item, :name => item_name, :parent => character
    character.perform 'inventory'
    expect(character.messages).to include(item_name)
  end
end
