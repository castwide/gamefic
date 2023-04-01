# frozen_string_literal: true

describe Gamefic::Plot do
  after :each do
    Gamefic::Plot.blocks.clear
  end

  it 'creates entities from scripts' do
    Gamefic.script do
      make Gamefic::Entity
    end
    plot = Gamefic::Plot.new
    expect(plot.entities.length).to eq(1)
    expect(plot.static.length).to eq(2)
  end

  it 'creates responses from scripts' do
    Gamefic.script do
      respond :command do |_actor|
        nil
      end
    end
    plot = Gamefic::Plot.new
    expect(plot.playbook.responses.length).to eq(1)
  end

  it 'raises an error on new responses after initialization' do
    plot = Gamefic::Plot.new
    expect { plot.respond(:mycommand) { |_| nil } }.to raise_error(FrozenError)
  end

  it 'creates scenes from scripts' do
    Gamefic.script do
      block :enter do |scene|
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
    expect(plot.scenebook.scenes.length).to eq(3)
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
    expect(player.next_cue.name).to be(:introduction)
  end

  it 'starts the introduction on ready' do
    Gamefic.script do
      introduction do |actor|
        actor.tell 'Hello, world!'
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    expect(plot.takes.first.scene).to be(plot.scenebook[:introduction])
    expect(player.messages).to include('Hello, world!')
  end

  it 'cues the default scene without an introduction' do
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    expect(plot.takes.first.scene).to be(plot.scenebook[:default_scene])
  end

  it 'cues the default scene from an introduction without a cue' do
    Gamefic.script { introduction }
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    plot.update
    plot.ready
    expect(plot.takes.first.scene).to be(plot.default_scene)
    expect(player.queue).to be_empty
  end

  it 'tracks player subplots' do
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    subplot = plot.branch Gamefic::Subplot, introduce: player
    expect(plot.subplots_featuring(player)).to eq([subplot])
    expect(plot.in_subplot?(player)).to be(true)
  end

  it 'deletes concluded subplots on update' do
    plot = Gamefic::Plot.new
    subplot = plot.branch Gamefic::Subplot
    expect(plot.subplots).to include(subplot)
    subplot.conclude
    plot.update
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
    player.cue plot.default_conclusion
    plot.ready
    plot.update
    expect(player[:concluded]).to be(true)
  end

  it 'concludes on conclusions' do
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    player.cue plot.default_conclusion
    plot.ready
    plot.update
    expect(plot).to be_concluded
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
      on_player_ready do |player|
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
end
