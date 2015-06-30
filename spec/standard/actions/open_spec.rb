describe "Open Action" do
  it "opens a closed container" do
    plot = Plot.new(Source.new(Gamefic::Sdk::GLOBAL_IMPORT_PATH))
    plot.import 'standard'
    room = plot.make Room, :name => 'room'
    container = plot.make Container, :name => 'container', :parent => room
    container.is :openable, :closed
    character = plot.make Character, :name => 'character', :parent => room
    character.perform "open container"
    expect(container.is?(:open)).to eq(true)
    expect(container.is?(:closed)).to eq(false)
  end
end
