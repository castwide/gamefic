describe Gamefic::Scriptable::Hooks do
  let(:object) { Object.new.extend(Gamefic::Scriptable::Hooks) }

  it 'adds player output blocks' do
    object.on_player_output {}
    expect(object.player_output_blocks).to be_one
  end
end
