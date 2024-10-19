# frozen_string_literal: true

describe Gamefic::Narrator do
  it 'runs on_player_conclude blocks' do
    klass = Class.new(Gamefic::Plot) do
      on_player_conclude do |player|
        player[:concluded] = true
      end
    end
    plot = klass.new
    narrator = Gamefic::Narrator.new(plot)
    player = narrator.cast
    player.cue plot.default_conclusion
    narrator.start
    expect(player[:concluded]).to be(true)
  end

  it 'runs on_ready blocks' do
    ran_on_ready = false
    klass = Class.new(Gamefic::Plot) do
      on_ready do
        ran_on_ready = true
      end
    end
    plot = klass.new
    narrator = Gamefic::Narrator.new(plot)
    narrator.start
    expect(ran_on_ready).to be(true)
  end

  it 'runs on_player_ready blocks' do
    klass = Class.new(Gamefic::Plot) do
      on_player_ready do |player|
        player[:ran_on_player_ready] = true
      end
    end
    plot = klass.new
    narrator = Gamefic::Narrator.new(plot)
    player = narrator.cast
    narrator.start
    expect(player[:ran_on_player_ready]).to be(true)
  end

  it 'runs on_update blocks' do
    ran_on_update = false
    klass = Class.new(Gamefic::Plot) do
      on_update do
        ran_on_update = true
      end
    end
    plot = klass.new
    narrator = Gamefic::Narrator.new(plot)
    narrator.cast
    narrator.start
    narrator.finish
    expect(ran_on_update).to be(true)
  end

  it 'runs on_player_update blocks' do
    klass = Class.new(Gamefic::Plot) do
      on_player_update do |player|
        player[:ran_on_player_update] = true
      end
    end
    plot = klass.new
    narrator = Gamefic::Narrator.new(plot)
    player = narrator.cast
    narrator.start
    narrator.finish
    expect(player[:ran_on_player_update]).to be(true)
  end

  it 'adds last_prompt and last_input to output' do
    klass = Class.new(Gamefic::Plot)
    plot = klass.new
    narrator = Gamefic::Narrator.new(plot)
    player = narrator.cast
    narrator.start
    player.queue.push 'my input'
    narrator.finish
    narrator.start
    expect(player.output.last_prompt).to eq('>')
    expect(player.output.last_input).to eq('my input')
  end
end
