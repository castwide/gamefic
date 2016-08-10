describe "Pathfinder" do
  it "finds a valid path" do
    plot = Plot.new
    room1 = plot.make Room, :name => 'room 1'
    room2 = plot.make Room, :name => 'room 2'
    room2.connect room1
    room2a = plot.make Room, :name => 'room 2a'
    room2a.connect room2
    room3 = plot.make Room, :name => 'room 3'
    room3.connect room2
    finder = Pathfinder.new(room1, room3)
    expect(finder.valid?).to eq(true)
    expect(finder.origin).to eq(room1)
    expect(finder.destination).to eq(room3)
    expect(finder.path).to eq([room2,room3])
  end
  it "finds an invalid path" do
    plot = Plot.new
    room1 = plot.make Room, :name => 'room 1'
    room2 = plot.make Room, :name => 'room 2'
    room2.connect room1
    room2a = plot.make Room, :name => 'room 2a'
    room2a.connect room2
    room3 = plot.make Room, :name => 'room 3'
    finder = Pathfinder.new(room1, room3)
    expect(finder.valid?).to eq(false)
    expect(finder.origin).to eq(room1)
    expect(finder.destination).to eq(room3)
    expect(finder.path).to eq([])
  end
end
