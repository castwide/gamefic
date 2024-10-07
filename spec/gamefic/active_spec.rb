# frozen_string_literal: true

describe Gamefic::Active do
  let(:object) { Gamefic::Entity.new.tap { |obj| obj.extend Gamefic::Active } }

  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  it 'performs a command' do
    Gamefic::Narrative.script do
      respond(:command) { |actor| actor[:executed] = true }
    end
    narrative = Gamefic::Narrative.new
    narrative.cast object
    object.perform 'command'
    expect(object[:executed]).to be(true)
  end

  it 'executes a command' do
    Gamefic::Narrative.script do
      room = make Gamefic::Entity, name: 'room'
      item = make Gamefic::Entity, name: 'item', parent: room
      respond(:command, item) { |actor| item[:commanded] = true }
    end
    narrative = Gamefic::Narrative.new
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
    Gamefic::Narrative.script do
      respond(:command) { |actor| actor.tell 'Keep this quiet' }
    end
    narr = Gamefic::Narrative.new
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
    Gamefic::Narrative.script { block :scene }
    narr = Gamefic::Narrative.new
    narr.cast object
    expect { object.cue :scene }.not_to raise_error
  end

  it 'cues a scene by class' do
    klass = Class.new(Gamefic::Scene::Default)
    Gamefic::Narrative.script { block :scene }
    narr = Gamefic::Narrative.new
    narr.cast object
    expect { object.cue klass }.not_to raise_error
  end

  it 'raises an error for non-conclusions' do
    Gamefic::Narrative.script { block :scene }
    narr = Gamefic::Narrative.new
    narr.cast object
    expect { object.conclude :scene }.to raise_error(ArgumentError)
  end

  it 'is not concluding by default' do
    narr = Gamefic::Narrative.new
    narr.cast object
    expect(object).not_to be_concluding
  end

  it 'is concluding when starting a conclusion' do
    Gamefic::Narrative.script { conclusion(:ending) {} }
    narr = Gamefic::Narrative.new
    narr.cast object
    object.cue :ending
    object.start_take
    expect(object).to be_concluding
  end

  it 'adds last_prompt and last_input to output' do
    plot = Gamefic::Plot.new
    plot.cast object
    plot.ready
    object.queue.push 'my input'
    plot.update
    plot.ready
    expect(object.output.last_prompt).to eq('>')
    expect(object.output.last_input).to eq('my input')
  end

  describe '#proceed' do
    it 'does nothing without an available action in dispatchers' do
      expect { object.proceed }.not_to raise_error
    end
  end

  describe '#output' do
    it 'is frozen' do
      expect(object.output).to be_frozen
    end
  end

  describe '#start_take' do
    it 'updates the output' do
      klass = Class.new(Gamefic::Narrative) do
        pause(:pause) { |actor| actor.tell 'pause message' }
      end
      narr = klass.new
      narr.cast object
      object.cue :pause
      object.start_take
      expect(object.output).to be_frozen
      expect(object.messages).to include('pause message')
      expect(object.output.scene[:name]).to be(:pause)
    end
  end
end
