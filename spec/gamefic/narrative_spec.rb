describe Gamefic::Narrative do
  after :each do
    Gamefic::Narrative.blocks.clear
  end

  describe 'class' do
    it 'adds a script' do
      blk = proc {}
      Gamefic::Narrative.script &blk
      expect(Gamefic::Narrative.blocks).to be_one
      expect(Gamefic::Narrative.blocks.first.type).to eq(:script)
      expect(Gamefic::Narrative.blocks.first.proc).to be(blk)
    end

    it 'adds a seed' do
      blk = proc {}
      Gamefic::Narrative.seed &blk
      expect(Gamefic::Narrative.blocks).to be_one
      expect(Gamefic::Narrative.blocks.first.type).to eq(:seed)
      expect(Gamefic::Narrative.blocks.first.proc).to be(blk)
    end
  end

  describe 'instance' do
    describe '#initialize' do
      it 'runs scripts' do
        executed = false
        blk = proc { executed = true }
        Gamefic::Narrative.script &blk
        Gamefic::Narrative.new
        expect(executed).to be(true)
      end

      it 'adds scenes from scripts' do
        Gamefic::Narrative.script do
          pause(:scene) { |actor| actor.tell 'Pause' }
        end
        narr = Gamefic::Narrative.new
        expect(narr.scenebook.scenes).to be_one
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
        Gamefic::Narrative.seed do
          pause(:scene) { |actor| actor.tell 'Pause' }
        end
        expect { Gamefic::Narrative.new }.to raise_error(RuntimeError)
      end

      it 'rejects actions from seeds' do
        Gamefic::Narrative.seed do
          respond(:think) { |actor| actor.tell 'You ponder your predicament.' }
        end
        expect { Gamefic::Narrative.new }.to raise_error(RuntimeError)
      end
    end
  end

  it 'delegates attributes' do
    Gamefic::Narrative.seed { @thing = make Gamefic::Entity, name: 'thing' }
    Gamefic::Narrative.attr_delegate :thing
    narr = Gamefic::Narrative.new
    expect(narr.thing).to be(narr.stage { @thing })
  end
end
