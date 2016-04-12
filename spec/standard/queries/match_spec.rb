# TODO Refactor this spec

describe "Match" do
  it "matches a reachable item" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.script 'standard'
    room = plot.make Room, :name => 'room'
    character = plot.make Character, :name => 'character', :parent => room
    container = plot.make Container, :name => 'container', :parent => room
    container.open = true
    item = plot.make Item, :name => 'item', :parent => container
    query = Query::Reachable.new
    objects = query.context_from(character)
    expect(objects).to eq([container, item])
    matches = query.match("item", objects)
    expect(matches.objects).to eq([item])
  end
end
