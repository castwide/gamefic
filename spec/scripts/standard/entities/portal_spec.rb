describe "Portal" do
  it "can have a direction" do
    plot = Plot.new
    portal = plot.make Portal, :direction => Direction::NORTH
    expect(portal.direction).to be(Direction::NORTH)
    expect(portal.name).to eq("north")
  end
  it "can have a name" do
    plot = Plot.new
    portal = plot.make Portal, :name => 'the staircase'
    expect(portal.direction).to be(nil)
    expect(portal.name).to eq("staircase")
  end
  it "can have a name and a direction" do
    plot = Plot.new
    portal = plot.make Portal, :name => 'the staircase', :direction => Direction::NORTH
    expect(portal.direction).to be(Direction::NORTH)
    expect(portal.name).to eq("staircase")
  end
end
