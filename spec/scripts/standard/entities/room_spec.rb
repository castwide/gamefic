describe "Room" do
  it "finds portals by destination" do
    plot = Gamefic::Plot.new(Gamefic::Plot::Source.new(Gamefic::Sdk::GLOBAL_SCRIPT_PATH))
    plot.script 'standard'
    room1 = plot.make Room, name: 'room 1'
    room2 = plot.make Room, name: 'room 2'
    room1.connect room2
    portal = room1.portal_to(room2)
    expect(portal.destination).to be(room2)
  end
end
