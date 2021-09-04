require "gamefic"

describe Gamefic::Active do
  it "performs an action" do
    plot = Gamefic::Plot.new
    character = plot.make Gamefic::Entity
    character.extend Gamefic::Active
    character.playbooks.push plot.playbook
    x = 0
    plot.respond :increment_number do |_actor|
      x += 1
    end
    character.perform "increment number"
    expect(x).to eq(1)
  end

  it 'performs an action with multiple arguments' do
    plot = Gamefic::Plot.new
    executed = false
    plot.respond :count, Gamefic::Query::Text.new(/one/), Gamefic::Query::Text.new(/two/) do |_actor, _one, _two|
      executed = true
    end
    plot.interpret 'count :one and :two', 'count :one :two'
    character = plot.make_player_character
    plot.introduce character
    character.perform "count one and two"
    expect(executed).to eq(true)
  end

  it "formats #tell messages into HTML paragraphs" do
    plot = Gamefic::Plot.new
    character = plot.make Gamefic::Entity
    character.extend Gamefic::Active
    character.playbooks.push plot.playbook
    character.tell "This is one paragraph."
    expect(character.messages).to eq("<p>This is one paragraph.</p>")
  end

  it "splits #tell messages into multiple paragraphs" do
    plot = Gamefic::Plot.new
    character = plot.make Gamefic::Entity
    character.extend Gamefic::Active
    character.playbooks.push plot.playbook
    character.tell "This is paragraph 1.\n\nThis is paragraph 2.\r\n\r\nThis is paragraph 3."
    expect(character.messages).to eq("<p>This is paragraph 1.</p><p>This is paragraph 2.</p><p>This is paragraph 3.</p>")
  end

  it 'performs actions quietly' do
    plot = Gamefic::Plot.new
    plot.respond :message do |actor|
      actor.tell 'Told message'
      actor.stream 'Streamed message'
    end
    character = plot.get_player_character
    plot.introduce character
    buffer = character.quietly('message')
    expect(buffer).to include('Told message')
    expect(buffer).to include('Streamed message')
    expect(character.messages).to be_empty
  end

  it 'streams a message' do
    character = Gamefic::Entity.new
    character.extend Gamefic::Active
    message = '<p>unprocessed text'.freeze
    character.stream message
    expect(character.messages).to eq(message)
  end

  it 'executes actions' do
    plot = Gamefic::Plot.new
    plot.respond :think do |actor|
      actor.tell "Thinking"
    end
    character = plot.make Gamefic::Entity
    character.extend Gamefic::Active
    character.playbooks.push plot.playbook
    character.execute :think
    expect(character.messages).to include("Thinking")
  end

  it 'executes actions with parameters' do
    plot = Gamefic::Plot.new
    room = plot.make Gamefic::Entity
    item = plot.make Gamefic::Entity, name: 'item', description: 'item description', parent: room
    plot.respond :look, item do |actor, _|
      actor.tell item.description
    end
    character = plot.make Gamefic::Actor
    plot.introduce character
    character.parent = room
    character.execute :look, item
    expect(character.messages).to include(item.description)
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
    character = Gamefic::Actor.new
    character.playbooks.push playbook
    character.execute :command
    expect(character.messages).not_to include('hidden')
    expect(character.messages).to include('visible')
  end

  it 'proceeds quietly' do
    playbook = Gamefic::World::Playbook.new
    playbook.respond :command do |actor|
      actor.tell "message"
    end
    character = Gamefic::Actor.new
    character.playbooks.push playbook
    character.execute :command, quietly: true
    expect(character.messages).not_to include('message')
  end

  describe '#conclude' do
    before :each do
      @plot = Gamefic::Plot.new
      @actor = @plot.make_player_character
      @plot.introduce @actor
    end

    it 'sets concluded' do
      @actor.conclude @plot.default_conclusion
      expect(@actor).to be_concluded
    end

    it 'raises for other scene types' do
      expect { @actor.conclude @plot.default_scene }.to raise_error(Gamefic::NotConclusionError)
    end
  end
end
