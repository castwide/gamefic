require 'gamefic'
include Gamefic

describe "Undo Action" do
  it "undoes the previous action" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    room = nil
    character = nil
    item = nil
    plot.script 'standard'
    plot.script 'undo'
    plot.stage do
      room = make Room, :name => "room"
      character = make Character, :name => "character", :parent => room
      item = make Item, :name => "item", :parent => room
    end
    plot.introduce character
    character.queue.unshift "take item"
    plot.update
    expect(item.parent).to be(character)
    character.queue.unshift "undo"
    plot.update
    expect(item.parent).to be(room)
  end
end
