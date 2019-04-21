describe Gamefic::World::Commands do
  let(:object) {
    object = Object.new
    object.extend Gamefic::World::Commands
    object
  }

  it "creates an action" do
    object.respond :command do |actor|
      puts 'command'
    end
    expect(object.playbook.actions.length).to eq(1)
    expect(object.playbook.actions.first.verb).to eq(:command)
  end

  it "creates a meta action" do
    object.meta :command do |actor|
      puts 'command'
    end
    expect(object.playbook.actions.length).to eq(1)
    expect(object.playbook.actions.first.verb).to eq(:command)
    expect(object.playbook.actions.first).to be_meta
  end

  it 'parses an action' do
    plot = Gamefic::Plot.new
    plot.make Gamefic::Entity, name: 'a thing'
    action = plot.parse(:touch, 'thing')
    expect(action.verb).to eq(:touch)
  end

  it 'raises errors on parses with bad tokens' do
    plot = Gamefic::Plot.new
    expect {
      plot.parse(:touch, 'a nonexistent thing')
    }.to raise_error(ArgumentError)
  end
end
