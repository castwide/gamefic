# frozen_string_literal: true

describe Gamefic::Active do
  let(:object) { Gamefic::Entity.new.tap { |obj| obj.extend Gamefic::Active } }

  it 'performs a command' do
    klass = Class.new(Gamefic::Narrative) do
      respond(:command) { |actor| actor[:executed] = true }
    end
    narrative = klass.new
    narrative.cast object
    object.perform 'command'
    expect(object[:executed]).to be(true)
  end

  it 'executes a command' do
    klass = Class.new(Gamefic::Narrative) do
      construct :room, Gamefic::Entity, name: 'room'
      construct :item, Gamefic::Entity, name: 'item', parent: room
      respond(:command, item) { item[:commanded] = true }
    end
    narrative = klass.new
    narrative.cast object
    object.parent = narrative.pick('room')
    item = narrative.pick('item')
    object.execute :command, item
    expect(item[:commanded]).to be(true)
  end

  it "formats #tell messages into HTML paragraphs" do
    object.tell "This is one paragraph."
    expect(object.messages).to eq("<p>This is one paragraph.</p>")
  end

  it "splits #tell messages into multiple paragraphs" do
    object.tell "This is paragraph 1.\n\nThis is paragraph 2.\r\n\r\nThis is paragraph 3."
    expect(object.messages).to eq("<p>This is paragraph 1.</p><p>This is paragraph 2.</p><p>This is paragraph 3.</p>")
  end

  it 'performs actions quietly' do
    klass = Class.new(Gamefic::Narrative) do
      respond(:command) { |actor| actor.tell 'Keep this quiet' }
    end
    narr = klass.new
    narr.cast object
    buffer = object.quietly 'command'
    expect(buffer).to include('Keep this quiet')
    expect(object.messages).to be_empty
  end

  it 'streams a message' do
    message = '<p>unprocessed text'.freeze
    object.stream message
    expect(object.messages).to eq(message)
  end

  it 'cues a scene' do
    klass = Class.new(Gamefic::Narrative) do
      block :scene
    end
    narr = klass.new
    narr.cast object
    expect { object.cue :scene }.not_to raise_error
  end

  it 'cues a scene by class' do
    scene_klass = Class.new(Gamefic::Scene::Base)
    plot_klass = Class.new(Gamefic::Plot)
    plot_klass.instance_exec { scene scene_klass, :scene }
    plot = plot_klass.new
    plot.cast object
    expect { object.cue scene_klass }.not_to raise_error
  end

  it 'is not concluding by default' do
    narr = Gamefic::Narrative.new
    narr.cast object
    expect(object).not_to be_concluding
  end

  describe '#proceed' do
    it 'performs the next action in the current dispatcher' do
      klass = Class.new(Gamefic::Plot) do
        respond(:command) { |actor| actor[:command] = 'first' }
        respond(:command) { |actor| actor.proceed }  
      end
      plot = klass.new
      plot.cast object
      object.perform 'command'
      expect(object[:command]).to eq('first')
    end

    it 'does nothing without an available action in dispatchers' do
      expect(object.proceed).to be_nil
    end
  end

  describe '#output' do
    it 'is frozen' do
      expect(object.output).to be_frozen
    end
  end
end
