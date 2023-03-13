# frozen_string_literal: true

class TestSubplot < Gamefic::Subplot
  script do
    @thing = make Gamefic::Entity, name: 'right thing'
    @room = make Gamefic::Entity, name: 'room'

    respond :look, Gamefic::Query::Siblings.new(@thing) do |actor, thing|
      actor.tell thing.name
    end

    introduction do |actor|
      actor.parent = @room
      @thing.parent = @room
    end
  end
end

describe 'Subplot snapshot' do
  context 'with entities in scripts' do
    it 'restores subplots' do
      Gamefic.script do
        @next_scene = pause do |actor|
          actor.tell "Done!"
          actor.prepare default_scene
        end

        introduction do |actor|
          branch Gamefic::Subplot, introduce: actor, next_cue: @next_scene
        end
      end
      plot = Gamefic::Plot.new
      next_scene = plot.stage { @next_scene }
      actor = plot.get_player_character
      plot.introduce actor
      snapshot = plot.save
      plot.subplots_featuring(actor).first.conclude
      expect(plot.subplots_featuring(actor)).to be_empty
      plot.restore snapshot
      plot.ready
      expect(plot.subplots_featuring(actor)).to be_one
      subplot = plot.subplots.first
      next_cue = subplot.instance_variable_get(:@next_cue)
      expect(next_cue).to be(next_scene)
    end

    it 'restores stage variables in subplots' do
      Gamefic.script do
        introduction do |actor|
          actor.parent = @room
          branch TestSubplot, introduce: actor, next_cue: default_scene
        end
      end
      plot = Gamefic::Plot.new
      actor = plot.get_player_character
      plot.introduce actor
      subplot = plot.subplots.first
      snapshot = plot.save
      subplot.stage { @thing.name = 'wrong thing' }
      expect(subplot.stage { @thing.name }).to eq('wrong thing')
      plot.restore snapshot
      subplot = plot.subplots.first
      thing = subplot.stage { @thing }
      expect(thing.name).to eq('right thing')
    end

    it 'restores actions associated with instance variables' do
      Gamefic.script do
        introduction do |actor|
          actor.parent = @room
          branch TestSubplot, introduce: actor, next_cue: default_scene
        end
      end
      plot = Gamefic::Plot.new
      actor = plot.get_player_character
      plot.introduce actor
      plot.ready
      snapshot = plot.save
      plot.restore snapshot
      t1 = plot.subplots.first.entities.find { |t| t.name == 'right thing' }
      t2 = plot.subplots.first.stage { @thing }
      t1.parent = actor.parent
      actor.perform 'look thing'
      expect(actor.messages).to include('right thing')
    end
  end
end
