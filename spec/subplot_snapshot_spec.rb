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
  after :each do
    Gamefic::Plot.blocks.clear
  end

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
        respond :look, Gamefic::Query::Text.new do |actor, _|
          actor.tell "Fuck."
        end

        introduction do |actor|
          branch TestSubplot, introduce: actor, next_cue: default_scene
        end
      end
      plot = Gamefic::Plot.new
      actor = plot.get_player_character
      plot.introduce actor
      plot.ready
      expect(actor.parent).to be(plot.subplots.first.stage { @room })
      snapshot = plot.save
      plot = Gamefic::Plot.new
      actor = plot.get_player_character
      plot.introduce actor
      plot.ready
      plot.restore snapshot
      expect(actor.parent).to be(plot.subplots.first.stage { @room })
      expect(plot.subplots.first.stage { @thing.parent }).to be(plot.subplots.first.stage { @room })
      # t1 = plot.subplots.first.entities.find { |t| t.name == 'right thing' }
      # t1.parent = actor.parent
      actor.perform 'look thing'
      expect(actor.messages).to include('right thing')
    end

    it 'does not duplicate subplot entities' do
      plot = Gamefic::Plot.new
      plot.branch TestSubplot
      snapshot = plot.save
      plot.restore snapshot
      t1 = plot.subplots.first.entities.find { |t| t.name == 'right thing' }
      t2 = plot.subplots.first.stage { @thing }
      expect(t1).to be(t2)
    end
  end
end
