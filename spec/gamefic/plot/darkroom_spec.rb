RSpec.describe Gamefic::Plot::Darkroom do
  it 'saves and restores a snapshot' do
    plot1 = Gamefic::Plot.new
    plot1.make Gamefic::Entity, name: 'thing'
    snapshot = plot1.save
    expect(snapshot).to be_a(String)

    plot2 = Gamefic::Plot.new
    plot2.restore snapshot
    expect(plot2.entities.first.name).to eq('thing')
  end
end
