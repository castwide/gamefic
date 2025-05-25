# frozen_string_literal: true

describe Gamefic::Narrative do
  describe 'class' do
    it 'adds a seed' do
      blk = proc {}
      klass = Class.new(Gamefic::Narrative) do
        seed &blk
      end
      expect(klass.seeds).to eq([blk])
    end

    it 'makes an entity' do
      klass = Class.new(Gamefic::Narrative) do
        make Gamefic::Entity, name: 'thing'
      end
      expect(klass.seeds).to be_one
      plot = klass.new
      expect(plot.entities).to be_one
    end

    it 'constructs an entity' do
      klass = Class.new(Gamefic::Narrative) do
        construct :thing, Gamefic::Entity, name: 'thing'
      end
      plot = klass.new
      expect(plot.thing).to be_a(Gamefic::Entity)
    end

    it 'picks an entity' do
      klass = Class.new(Gamefic::Narrative) do
        make Gamefic::Entity, name: 'room'
        make Gamefic::Entity, name: 'thing', parent: pick('room')
      end
      plot = klass.new
      thing = plot.pick('thing')
      room = plot.pick('room')
      expect(thing.parent).to be(room)
    end

    it 'raises pick! errors' do
      klass = Class.new(Gamefic::Narrative) do
        make Gamefic::Entity, name: 'thing', parent: pick!('not_a_thing')
      end
      expect { klass.new }.to raise_error(RuntimeError)
    end
  end

  describe 'instance' do
    describe '#initialize' do
      it 'adds scenes from scripts' do
        klass = Class.new(Gamefic::Narrative) do
          pause(:scene) {}
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
        klass = Class.new(Gamefic::Narrative) do
          seed &blk
        end
        narr = klass.new
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

    describe '#introduce' do
      it 'runs introductions in order of inclusion' do
        klass = Class.new(Gamefic::Narrative) do
          introduction do |actor|
            actor.stream 'first...'
          end

          introduction do |actor|
            actor.stream 'second'
          end
        end

        plot = klass.new
        actor = plot.introduce
        expect(actor.messages).to eq('first...second')
      end
    end
  end

  it 'marshals' do
    narr = NarrativeWithFeatures.new

    plyr = Gamefic::Actor.new
    narr.cast plyr

    dump = Marshal.dump(narr)
    rest = Marshal.load(dump)
    expect(rest).to be_a(NarrativeWithFeatures)
    expect(rest.players.first.narratives.to_a).to eq([rest])
  end
end
