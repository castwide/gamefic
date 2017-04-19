require 'gamefic'
include Gamefic

describe "Undo Action" do
  it "undoes the previous action" do
    plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    plot.script 'undo'
    room = plot.make Room, :name => "room"
    character = plot.make Character, :name => "character", :parent => room
    item = plot.make Item, :name => "item", :parent => room
    plot.introduce character
    character.queue.unshift "take item"
    plot.ready
    plot.update
    expect(item.parent).to be(character)
    character.queue.unshift "undo"
    plot.ready
    plot.update
    expect(item.parent).to be(room)
  end
end
