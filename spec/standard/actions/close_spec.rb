describe "Close Action" do
  it "closes an open container" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.import 'standard'
    room = plot.make Room, :name => 'room'
    container = plot.make Container, :name => 'container', :parent => room
    container.open = true
    character = plot.make Character, :name => 'character', :parent => room
    character.perform "close container"
    expect(container.open?).to eq(false)
  end
end
