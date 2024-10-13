# frozen_string_literal: true

RSpec.describe Gamefic::Plot do
  it 'creates responses' do
    klass = Class.new(Gamefic::Plot) do
      respond :command do |_actor|
        nil
      end
    end
    plot = klass.new
    puts plot.responses.inspect
    expect(plot.responses).to be_one
  end

  it 'cues the introduction' do
    Gamefic::Plot.script do
      introduction do |actor|
        actor.tell 'Hello, world!'
      end
    end
    plot = Gamefic::Plot.new
    player = plot.introduce
    expect(player.messages).to include('Hello, world!')
  end

  it 'starts the default scene after the introduction' do
    Gamefic::Plot.script do
      introduction do |actor|
        actor[:introduced] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.introduce
    plot.ready
    expect(player.next_cue.scene).to be_a(plot.default_scene)
  end

  it 'tracks player subplots' do
    plot = Gamefic::Plot.new
    player = plot.introduce
    plot.ready
    subplot = plot.branch Gamefic::Subplot, introduce: player
    expect(player.narratives.to_a).to eq([plot, subplot])
  end

  it 'deletes concluded subplots on ready' do
    plot = Gamefic::Plot.new
    subplot = plot.branch Gamefic::Subplot
    expect(plot.subplots).to include(subplot)
    subplot.conclude
    plot.ready
    expect(plot.subplots).to be_empty
  end

  it 'runs on_player_conclude blocks' do
    klass = Class.new(Gamefic::Plot) do
      on_player_conclude do |player|
        player[:concluded] = true
      end
    end
    plot = klass.new
    player = plot.introduce
    player.cue plot.default_conclusion
    plot.ready
    expect(player[:concluded]).to be(true)
  end

  it 'runs on_ready blocks' do
    ran_on_ready = false
    Gamefic::Plot.script do
      on_ready do
        ran_on_ready = true
      end
    end
    plot = Gamefic::Plot.new
    plot.ready
    expect(ran_on_ready).to be(true)
  end

  it 'runs on_player_ready blocks' do
    Gamefic::Plot.script do
      on_player_ready do |player|
        player[:ran_on_player_ready] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.introduce
    plot.ready
    expect(player[:ran_on_player_ready]).to be(true)
  end

  it 'runs on_update blocks' do
    ran_on_update = false
    Gamefic::Plot.script do
      on_update do
        ran_on_update = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.introduce
    plot.ready
    plot.update
    expect(ran_on_update).to be(true)
  end

  it 'runs on_player_update blocks' do
    Gamefic::Plot.script do
      on_player_update do |player|
        player[:ran_on_player_update] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.introduce
    plot.ready
    plot.update
    expect(player[:ran_on_player_update]).to be(true)
  end

  it 'supports multiple players' do
    plot = Gamefic::Plot.new
    player1 = plot.introduce
    player2 = plot.introduce
    expect(plot.players).to eq([player1, player2])
  end

  it 'uncasts players from plot and subplots' do
    plot = Gamefic::Plot.new
    player = plot.introduce
    plot.branch Gamefic::Subplot, introduce: player
    plot.uncast player

    expect(plot.players).to be_empty
    expect(plot.subplots.first.players).to be_empty
  end

  it 'concludes its subplots' do
    plot = Gamefic::Plot.new
    actor = plot.introduce
    plot.branch Gamefic::Subplot, introduce: actor
    actor.cue plot.default_conclusion
    plot.ready
    expect(plot.subplots).to be_empty
    expect(actor.narratives).to be_one
  end
end
