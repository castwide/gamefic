describe Gamefic::Narrative do
  describe 'class' do
    it 'adds a script' do
      blk = proc {}
      Gamefic::Narrative.script &blk
      expect(Gamefic::Narrative.blocks).to be_one
      expect(Gamefic::Narrative.blocks.first).to be_a(Gamefic::Block::Script)
    end

    it 'adds a seed' do
      blk = proc {}
      Gamefic::Narrative.seed &blk
      expect(Gamefic::Narrative.blocks).to be_one
      expect(Gamefic::Narrative.blocks.first).to be_a(Gamefic::Block::Seed)
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
        expect(narr.rulebook.scenes.names).to be_one
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
        expect(Gamefic::Logging.logger).to receive(:warn).with(/Rulebook was modified in seeds/)
        Gamefic::Narrative.seed do
          pause(:scene) { |actor| actor.tell 'Pause' }
        end
        Gamefic::Narrative.new
      end

      it 'rejects actions from seeds' do
        expect(Gamefic::Logging.logger).to receive(:warn).with(/Rulebook was modified in seeds/)
        Gamefic::Narrative.seed do
          respond(:think) { |actor| actor.tell 'You ponder your predicament.' }
        end
        Gamefic::Narrative.new
      end
    end
  end

  it 'marshals' do
    Gamefic::Narrative.script do
      respond(:cmd) { |_| nil }
    end
    narr = Gamefic::Narrative.new

    plyr = Gamefic::Actor.new
    narr.enter plyr

    dump = Marshal.dump(narr)
    rest = Marshal.load(dump)
    expect(rest).to be_a(Gamefic::Narrative)
    expect(rest.players.first.narratives).to eq([rest].to_set)
  end
end
