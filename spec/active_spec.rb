describe Gamefic::Active do
  let(:object) { Gamefic::Entity.new.tap { |obj| obj.extend Gamefic::Active } }

  it 'performs a command' do
    playbook = Gamefic::World::Playbook.new
    playbook.respond(:command) { |actor| actor[:executed] = true }
    object.playbooks.push playbook
    object.perform 'command'
    expect(object[:executed]).to be(true)
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
    playbook = Gamefic::World::Playbook.new
    playbook.respond(:command) { |actor| actor.tell 'Keep this quiet' }
    object.playbooks.push playbook
    buffer = object.quietly 'command'
    expect(buffer).to include('Keep this quiet')
    expect(object.messages).to be_empty
  end

  it 'streams a message' do
    message = '<p>unprocessed text'.freeze
    object.stream message
    expect(object.messages).to eq(message)
  end

  it 'proceeds quietly' do
    playbook = Gamefic::World::Playbook.new
    playbook.respond :command do |actor|
      actor.tell "hidden"
    end
    playbook.respond :command do |actor|
      actor.proceed quietly: true
      actor.tell "visible"
    end
    object.playbooks.push playbook
    object.execute :command
    expect(object.messages).not_to include('hidden')
    expect(object.messages).to include('visible')
  end

  it 'cues a scene by name' do
    scenebook = Gamefic::World::Scenebook.new
    scene = scenebook.block(:dummy)
    object.scenebooks.push scenebook
    expect { object.cue :dummy }.not_to raise_error
  end

  it 'cues a scene by instance' do
    scenebook = Gamefic::World::Scenebook.new
    scene = scenebook.block(:dummy)
    object.scenebooks.push scenebook
    expect { object.cue scene }.not_to raise_error
  end
end
