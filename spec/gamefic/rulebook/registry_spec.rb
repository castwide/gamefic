describe Gamefic::Rulebook::Registry do
  let(:narrative) { Gamefic::Narrative.new }

  it 'registers a rulebook' do
    expect(Gamefic::Rulebook::Registry.register(narrative)).to be_a(Gamefic::Rulebook)
  end

  it 'unregisters a rulebook' do
    Gamefic::Rulebook::Registry.register narrative
    Gamefic::Rulebook::Registry.unregister narrative
    expect(Gamefic::Rulebook::Registry.registered?(narrative)).to be_falsey
  end

  it 'clears the rulebook' do
    Gamefic::Rulebook::Registry.register narrative
    Gamefic::Rulebook::Registry.clear
    expect(Gamefic::Rulebook::Registry.map).to be_empty
  end
end
