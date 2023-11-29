require 'date'

describe Gamefic::Snapshot do
  let(:plot) do
    Gamefic::Plot.script do
      @room = make Gamefic::Entity, name: 'room'
      @thing = make Gamefic::Entity, name: 'thing', parent: @room

      # Make sure various other objects can get serialized
      @object = Object.new
      @date_time = DateTime.new

      introduction do |actor|
        actor.parent = @room
        branch Gamefic::Subplot, introduce: actor, configured: @thing
      end

      respond :look, @thing do |actor, thing|
        actor.tell "You see #{thing}"
      end
    end

    Gamefic::Plot.new.tap do |plot|
      player = plot.make_player_character
      plot.introduce player
      plot.ready
    end
  end

  let(:restored) { Gamefic::Plot.restore plot.save }

  it 'freezes theaters' do
    expect(restored.theater).to be_frozen
  end

  it 'restores players' do
    player = restored.players.first
    expect(player.playbooks.to_a).to eq([restored.playbook, restored.subplots.first.playbook])
    expect(player.scenebooks.to_a).to eq([restored.scenebook, restored.subplots.first.scenebook])
  end

  it 'handles restored introduction cues' do
    restored.ready
  end

  it 'restores subplots' do
    expect(restored.subplots).to be_one
  end

  it 'freezes subplot theaters' do
    expect(restored.subplots.first.theater).to be_frozen
  end

  it 'restores stage instance variables' do
    thing = restored.stage { @thing }
    expect(thing.name).to eq('thing')
    picked = restored.pick('thing')
    expect(thing).to be(picked)
  end

  it 'restores references in actions' do
    player = restored.players.first
    player.cue :default_scene
    restored.ready
    player.perform 'look thing'
    expect(player.messages).to include('thing')
  end

  it 'restores subplot config data' do
    expect(restored.subplots.first.config[:configured]).to be(restored.stage { @thing })
  end

  it 'generates a reproducible digest' do
    digest = Gamefic::Snapshot.digest(plot)
    expect(digest).to eq(plot.digest)
  end
end
