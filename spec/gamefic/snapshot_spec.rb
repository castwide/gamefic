# frozen_string_literal: true

require 'date'

class SnapshotTestPlot < Gamefic::Plot
  construct :room, Gamefic::Entity,
            name: 'room'

  construct :thing, Gamefic::Entity,
            name: 'thing',
            parent: room

  construct :unicode, Gamefic::Entity,
            name: 'ぇワ'

  seed do
    # Make sure various other objects can get serialized
    @object = Object.new
    @date_time = DateTime.new
  end

  multiple_choice :anon_scene do
    on_start do |_actor, props|
      props.options.push 'one', 'two'
    end
  end

  introduction do |actor|
    actor.parent = room
    branch Gamefic::Subplot, introduce: actor, configured: thing
  end

  respond :look, thing do |actor, thing|
    actor.tell "You see #{thing}"
  end

  respond :take, thing do |actor, thing|
    thing.parent = actor
  end
end

describe Gamefic::Snapshot do
  let(:plot) { SnapshotTestPlot.new }
  let(:player) { plot.introduce }
  let(:narrator) { Gamefic::Narrator.new(plot) }

  before :each do
    player # hitit
    narrator.start
  end

  context 'after the introduction' do
    let(:restored) { SnapshotTestPlot.restore plot.save }

    it 'restores players' do
      player = restored.players.first
      expect(player.narratives.to_set).to eq([restored, restored.subplots.first].to_set)
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
      player.cue restored.default_scene
      player.perform 'look thing'
      expect(player.messages).to include('thing')
    end

    it 'restores subplot config data' do
      expect(restored.subplots.first.config[:configured]).to be(restored.instance_exec { @thing })
    end

    it 'retains player configuration after save' do
      expect(plot.players).to be_one
      expect(plot.players.first.narratives.length).to eq(2)
    end
  end

  context 'after a game turn' do
    it 'restores output' do
      player.queue.push 'look thing'
      narrator.finish
      narrator.start

      snapshot = plot.save
      restored_plot = Gamefic::Snapshot.restore snapshot
      restored_player = restored_plot.players.first
      expect(restored_player.output.to_hash).to eq(player.output.to_hash)
      expect(restored_player.output.to_hash).to eq(player.output.to_hash)
    end

    it 'restores entity changes' do
      player.queue.push 'take thing'
      narrator.finish
      narrator.start

      snapshot = plot.save
      restored_plot = Gamefic::Snapshot.restore snapshot
      restored_player = restored_plot.players.first
      expect(restored_plot.pick('thing').parent).to be(restored_player)
    end

    it 'restores with anonymous scenes' do
      player.cue :anon_scene
      narrator.start

      snapshot = plot.save
      restored_plot = Gamefic::Snapshot.restore snapshot
      expect(restored_plot.players.first.last_cue.key).to be(:anon_scene)
    end
  end
end
