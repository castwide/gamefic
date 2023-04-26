describe Gamefic::Active do
  let(:object) { Gamefic::Entity.new.tap { |obj| obj.extend Gamefic::Active } }

  let(:stage_func) { Proc.new { |*args, &block| block.call *args } }

  it 'performs a command' do
    playbook = Gamefic::Playbook.new(stage_func)
    playbook.respond_with Gamefic::Response.new(:command, stage_func) { |actor| actor[:executed] = true }
    object.playbooks.add playbook
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
    playbook = Gamefic::Playbook.new(stage_func)
    playbook.respond_with Gamefic::Response.new(:command, stage_func) { |actor| actor.tell 'Keep this quiet' }
    object.playbooks.add playbook
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
    playbook = Gamefic::Playbook.new(stage_func)
    playbook.respond_with(Gamefic::Response.new(:command, stage_func) do |actor|
      actor.tell "hidden"
    end)
    playbook.respond_with(Gamefic::Response.new(:command, stage_func) do |actor|
      actor.proceed quietly: true
      actor.tell "visible"
    end)
    object.playbooks.add playbook
    object.execute :command
    expect(object.messages).not_to include('hidden')
    expect(object.messages).to include('visible')
  end

  it 'cues a scene' do
    scenebook = Gamefic::Scenebook.new(stage_func)
    scenebook.add Gamefic::Scene.new(:scene, stage_func)
    object.scenebooks.add scenebook
    expect { object.cue :scene }.not_to raise_error
  end

  it 'raises an error for non-conclusions' do
    scenebook = Gamefic::Scenebook.new(stage_func)
    scenebook.add Gamefic::Scene.new(:scene, stage_func)
    object.scenebooks.add scenebook
    expect { object.conclude :scene }.to raise_error(ArgumentError)
  end

  it 'is not concluding by default' do
    scenebook = Gamefic::Scenebook.new(stage_func)
    object.scenebooks.add scenebook
    expect(object).not_to be_concluding
  end

  it 'is concluding when starting a conclusion' do
    scenebook = Gamefic::Scenebook.new(stage_func)
    scenebook.add Gamefic::Scene.new(:ending, stage_func, rig: Gamefic::Rig::Conclusion)
    object.scenebooks.add scenebook
    object.cue :ending
    take = object.start_cue
    take.start
    expect(object).to be_concluding
  end
end
