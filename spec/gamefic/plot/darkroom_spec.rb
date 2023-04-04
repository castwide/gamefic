RSpec.describe Gamefic::Plot::Darkroom do
  it 'saves and restores entities' do
    plot1 = Gamefic::Plot.new
    plot1.make Gamefic::Entity, name: 'thing'
    snapshot = plot1.save

    plot2 = Gamefic::Plot.new
    plot2.restore snapshot
    expect(plot2.entities.first.name).to eq('thing')
  end

  it 'saves and restores subplots' do
    plot1 = Gamefic::Plot.new
    plot1.branch Gamefic::Subplot
    snapshot = plot1.save

    plot2 = Gamefic::Plot.new
    plot2.restore snapshot
    expect(plot2.subplots.first).to be_a(Gamefic::Subplot)
  end
end
