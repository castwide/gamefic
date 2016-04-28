require 'securerandom'

describe "Inventory Action" do
  it "lists an item in a character's inventory" do
    plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.script 'standard'
    # TODO: We need to put the character in a room so the has-enough-light room won't cause an error
    room = plot.make Room, :name => 'room'
    character = plot.make MetaCharacter, :name => 'character', :parent => room
    item_name = SecureRandom.hex
    item = plot.make Item, :name => item_name, :parent => character
    character.perform 'inventory'
    expect(character.output.join("\n").include?(item_name)).to be(true)
  end
end
