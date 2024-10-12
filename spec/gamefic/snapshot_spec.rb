# frozen_string_literal: true

require 'date'

class SnapshotTestPlot < Gamefic::Plot
  seed do
    @room = make Gamefic::Entity, name: 'room'
    @thing = make Gamefic::Entity, name: 'thing', parent: @room

    # Make sure various other objects can get serialized
    @object = Object.new
    @date_time = DateTime.new
  end

  introduction do |actor|
    actor.parent = @room
    branch Gamefic::Subplot, introduce: actor, configured: @thing
  end

  respond :look, lazy_pick('thing') do |actor, thing|
    actor.tell "You see #{thing}"
  end

  respond :take, lazy_pick('thing') do |actor, thing|
    thing.parent = actor
  end
end

describe Gamefic::Snapshot do
  let(:plot) do
    SnapshotTestPlot.new.tap do |plot|
      plot.introduce
      plot.ready
    end
  end

  context 'after the introduction' do
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
  end

  context 'after a game turn' do
    it 'restores output' do
      player = plot.players.first
      player.queue.push 'look thing'
      plot.update
      plot.ready

      snapshot = plot.save
      restored_plot = Gamefic::Snapshot.restore snapshot
      restored_player = restored_plot.players.first
      expect(restored_player.output.to_hash).to eq(player.output.to_hash)
      expect(restored_player.output.to_hash).to eq(player.output.to_hash)
    end

    it 'restores entity changes' do
      player = plot.players.first
      player.queue.push 'take thing'
      plot.update
      plot.ready

      snapshot = plot.save
      restored_plot = Gamefic::Snapshot.restore snapshot
      restored_player = restored_plot.players.first
      expect(restored_plot.pick('thing').parent).to be(restored_player)
    end

    it 'saves plots with chapters' do
      plot = PlotWithChapter.new
      expect { Gamefic::Snapshot.restore plot.save }.not_to raise_error
    end
  end
end
