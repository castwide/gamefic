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
end
