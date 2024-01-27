# frozen_string_literal: true

require 'date'

describe Gamefic::Snapshot do
  let(:plot) do
    Gamefic::Plot.seed do
      @room = make Gamefic::Entity, name: 'room'
      @thing = make Gamefic::Entity, name: 'thing', parent: @room

      # Make sure various other objects can get serialized
      @object = Object.new
      @date_time = DateTime.new
    end

    Gamefic::Plot.script do
      introduction do |actor|
        actor.parent = @room
        branch Gamefic::Subplot, introduce: actor, configured: @thing
      end

      respond :look, @thing do |actor, thing|
        actor.tell "You see #{thing}"
      end
    end

    Gamefic::Plot.new.tap do |plot|
      plot.introduce
      plot.ready
    end
  end

  let(:restored) { Gamefic::Plot.restore plot.save }

  it 'restores players' do
    player = restored.players.first
    expect(player.epic.narratives).to eq([restored, restored.subplots.first].to_set)
  end

  it 'handles restored introduction cues' do
    restored.ready
  end

  it 'restores subplots' do
    expect(restored.subplots).to be_one
  end

  it 'restores stage instance variables' do
    thing = restored.instance_variable_get(:@thing)
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
    expect(restored.subplots.first.config[:configured]).to be(restored.instance_exec { @thing })
  end

  it 'retains player configuration after save' do
    expect(plot.players).to be_one
    expect(plot.players.first.epic.narratives.length).to eq(2)
  end

  it 'warns when scripts change restored plots' do
    # @todo Opal marshal dumps are not idempotent
    next if RUBY_ENGINE == 'opal'

    expect(Gamefic::Logging.logger).to receive(:warn).with(/Scripts modified/i)
    Gamefic::Plot.script { @foo = 'foo' }
    plot = Gamefic::Plot.new
    plot.instance_exec { @foo = 'bar' }
    Gamefic::Plot.restore plot.save
  end
end
