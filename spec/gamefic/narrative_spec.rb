# frozen_string_literal: true

describe Gamefic::Narrative do
  describe 'class' do
    it 'adds a script' do
      blk = proc {}
      Gamefic::Narrative.script &blk
      expect(Gamefic::Narrative.blocks).to be_one
      expect(Gamefic::Narrative.blocks.first).to be_script
    end

    it 'adds a seed' do
      blk = proc {}
      Gamefic::Narrative.seed &blk
      expect(Gamefic::Narrative.blocks).to be_one
      expect(Gamefic::Narrative.blocks.first).to be_seed
    end

    it 'appends a chapter' do
      chap_klass = Class.new(Gamefic::Chapter)
      plot_klass = Class.new(Gamefic::Narrative) do
        append chap_klass
      end

      expect(plot_klass.appended_chapters).to include(chap_klass)

      plot = plot_klass.new
      expect(plot.chapters).to be_one
      expect(plot.chapters.first).to be_a(chap_klass)
    end
  end

  describe 'instance' do
    describe '#initialize' do
      it 'runs scripts' do
        executed = false
        Gamefic::Narrative.script { executed = true }
        Gamefic::Narrative.new
        expect(executed).to be(true)
      end

      it 'adds scenes from scripts' do
        Gamefic::Narrative.script do
          pause(:scene) { |actor| actor.tell 'Pause' }
        end
        narr = Gamefic::Narrative.new
        expect(narr.rulebook.scenes.names).to eq(%i[scene default_scene default_conclusion])
      end

      it 'adds actions from scripts' do
        Gamefic::Narrative.script do
          respond(:think) { |actor| actor.tell 'You ponder your predicament.' }
        end
        narr = Gamefic::Narrative.new
        expect(narr.rulebook.responses).to be_one
      end

      it 'adds entities from seeds' do
        blk = proc { make Gamefic::Entity, name: 'entity' }
        Gamefic::Narrative.seed &blk
        narr = Gamefic::Narrative.new
        expect(narr.entities).to be_one
      end

      it 'rejects scenes from seeds' do
        # @todo Maybe raise ScriptError or SeedError
        Gamefic::Narrative.seed do
          pause(:scene) { |actor| actor.tell 'Pause' }
        end
        expect { Gamefic::Narrative.new }.to raise_error(NoMethodError)
      end

      it 'rejects actions from seeds' do
        # @todo Maybe raise ScriptError or SeedError
        Gamefic::Narrative.seed do
          respond(:think) { |actor| actor.tell 'You ponder your predicament.' }
        end
        expect { Gamefic::Narrative.new }.to raise_error(NoMethodError)
      end
    end
  end

  it 'marshals' do
    Gamefic::Narrative.script do
      respond(:cmd) { |_| nil }
    end
    narr = Gamefic::Narrative.new

    plyr = Gamefic::Actor.new
    narr.cast plyr

    narr.detach
    dump = Marshal.dump(narr)
    rest = Marshal.load(dump)
    expect(rest).to be_a(Gamefic::Narrative)
    expect(rest.players.first.epic.narratives).to eq([rest].to_set)
  end
end
