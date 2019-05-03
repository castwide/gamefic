require "gamefic"

describe Gamefic::Active do
  it "performs an action" do
    plot = Gamefic::Plot.new
    character = plot.make Gamefic::Entity
    character.extend Gamefic::Active
    character.playbooks.push plot.playbook
    x = 0
    plot.respond :increment_number do |actor|
      x += 1
    end
    character.perform "increment number"
    expect(x).to eq(1)
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
      actor.tell 'Message command'
    end
    character = plot.get_player_character
    plot.introduce character
    buffer = character.quietly('message')
    expect(buffer).to include('Message command')
    expect(character.messages).to be_empty
  end
end
