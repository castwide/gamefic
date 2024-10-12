# frozen_string_literal: true

describe Gamefic::Narrative do
  describe 'class' do
    it 'adds a seed' do
      blk = proc {}
      klass = Class.new(Gamefic::Narrative) do
        seed &blk
      end
      expect(klass.seeds).to be_one
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
        klass = Class.new(Gamefic::Narrative) do
          pause(:scene) { |actor| actor.tell 'Pause' }
        end
        narr = klass.new
        expect(narr.named_scenes.keys).to eq(%i[scene])
      end

      it 'adds actions from scripts' do
        klass = Class.new(Gamefic::Narrative) do
          respond(:think) { |actor| actor.tell 'You ponder your predicament.' }
        end
        narr = klass.new
        expect(narr.responses).to be_one
      end

      it 'adds entities from seeds' do
        blk = proc { make Gamefic::Entity, name: 'entity' }
        Gamefic::Narrative.seed &blk
        narr = Gamefic::Narrative.new
        expect(narr.entities).to be_one
      end

      it 'rejects scenes from seeds' do
        klass = Class.new(Gamefic::Narrative) do
          seed do
            pause(:scene) { |actor| actor.tell 'Pause' }
          end
        end
        expect { klass.new }.to raise_error(NoMethodError)
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

    dump = Marshal.dump(narr)
    rest = Marshal.load(dump)
    expect(rest).to be_a(Gamefic::Narrative)
    expect(rest.players.first.epic.narratives).to eq([rest].to_set)
  end
end
