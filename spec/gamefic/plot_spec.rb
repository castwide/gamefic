# frozen_string_literal: true

RSpec.describe Gamefic::Plot do
  it 'creates entities from scripts' do
    Gamefic.script do
      make Gamefic::Entity
    end
    plot = Gamefic::Plot.new
    expect(plot.entities.length).to eq(1)
  end

  it 'creates responses from scripts' do
    Gamefic.script do
      respond :command do |_actor|
        nil
      end
    end
    plot = Gamefic::Plot.new
    expect(plot.rulebook.responses.length).to eq(1)
  end

  it 'raises an error on new responses after initialization' do
    plot = Gamefic::Plot.new
    expect { plot.respond(:mycommand) { |_| nil } }.to raise_error(FrozenError)
  end

  it 'creates scenes from scripts' do
    Gamefic.script do
      block :scene do |scene|
        scene.on_start do |actor, props|
          actor.tell "What's your name?"
          props.prompt 'Enter your name:'
        end
        scene.on_finish do |actor, props|
          actor.tell "Hello, #{props.input}!"
        end
      end
    end
    plot = Gamefic::Plot.new
    # There are 3 scenes because the plot created 2 defaults
    expect(plot.rulebook.scenes.all.length).to eq(3)
  end

  it 'raises an error on new responses after initialization' do
    plot = Gamefic::Plot.new
    expect { plot.block :scene }.to raise_error(FrozenError)
  end

  it 'cues the introduction' do
    Gamefic.script do
      introduction do |actor|
        actor.tell 'Hello, world!'
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    expect(player.messages).to include('Hello, world!')
  end

  it 'starts the default scene after the introduction' do
    Gamefic.script do
      introduction do |actor|
        actor[:introduced] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    expect(player.next_cue).to be_nil
  end

  it 'tracks player subplots' do
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    subplot = plot.branch Gamefic::Subplot, introduce: player
    expect(plot.subplots_featuring(player)).to eq([subplot])
    expect(plot.in_subplot?(player)).to be(true)
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
    Gamefic.script do
      on_player_conclude do |player|
        player[:concluded] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    player.cue :default_conclusion
    plot.ready
    expect(player[:concluded]).to be(true)
  end

  it 'runs on_ready blocks' do
    ran_on_ready = false
    Gamefic.script do
      on_ready do
        ran_on_ready = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    expect(ran_on_ready).to be(true)
  end

  it 'runs on_player_ready blocks' do
    Gamefic.script do
      on_player_ready do |player|
        player[:ran_on_player_ready] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    expect(player[:ran_on_player_ready]).to be(true)
  end

  it 'runs on_update blocks' do
    ran_on_update = false
    Gamefic.script do
      on_update do
        ran_on_update = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    plot.update
    expect(ran_on_update).to be(true)
  end

  it 'runs on_player_update blocks' do
    Gamefic.script do
      on_player_update do |player|
        player[:ran_on_player_update] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    plot.update
    expect(player[:ran_on_player_update]).to be(true)
  end

  it 'supports multiple players' do
    plot = Gamefic::Plot.new
    player1 = plot.make_player_character
    plot.introduce player1
    player2 = plot.make_player_character
    plot.introduce player2
    expect(plot.players).to eq([player1, player2])
  end

  it 'warns of data changes during script setup' do
    expect(Gamefic::Logging.logger).to receive(:warn).with(/data changed during script setup/)
    Gamefic.script do
      session[:test] = 'bad practice'
    end
    Gamefic::Plot.new
  end

  it 'exeunts players from plot and subplots' do
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.branch Gamefic::Subplot, introduce: player
    plot.exeunt player

    expect(plot.players).to be_empty
    expect(plot.subplots.first.players).to be_empty
  end
end
