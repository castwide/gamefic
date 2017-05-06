# TODO Refactor this spec

describe "Match" do
  it "matches a reachable item" do
    plot = Plot.new(Source::File.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    container = plot.make Container, :name => 'container', :parent => room
    container.open = true
    item = plot.make Item, :name => 'item', :parent => container
    query = Query::Reachable.new
    objects = query.context_from(character)
    expect(objects).to eq([container, item])
    matches = query.resolve(character, "item")
    expect(matches).to eq([item])
  end
end
