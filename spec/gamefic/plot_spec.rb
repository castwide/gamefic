# frozen_string_literal: true

RSpec.describe Gamefic::Plot do
  after :each do
    Gamefic::Plot.blocks.clear
  end

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
    expect(plot.playbook.responses.length).to eq(1)
  end

  it 'raises an error on new responses after initialization' do
    plot = Gamefic::Plot.new
    expect { plot.respond(:mycommand) { |_| nil } }.to raise_error(FrozenError)
  end

  it 'creates scenes from scripts' do
    Gamefic.script do
      @scene = block :scene do |scene|
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
    # There are 4 scenes because the plot created 3 defaults
    expect(plot.scenebook.scenes.length).to eq(4)
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
    take = player.start_cue
    expect(take.scene.name).to be(plot.intro_name)
  end

  it 'starts the introduction on ready' do
    Gamefic.script do
      introduction do |actor|
        actor[:introduced] = true
      end
    end
    plot = Gamefic::Plot.new
    player = plot.make_player_character
    plot.introduce player
    plot.ready
    expect(plot.takes.first.scene.name).to be(plot.intro_name)
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

  describe 'snapshot' do
    let(:plot) do
      Gamefic::Plot.script do
        @room = make Gamefic::Entity, name: 'room'
        @thing = make Gamefic::Entity, name: 'thing', parent: @room

        introduction do |actor|
          actor.parent = @room
        end

        respond :think do |actor|
          actor.tell 'Yer thinkin'
        end

        respond :look, @thing do |actor, thing|
          actor.tell "You see #{thing}"
        end
      end
      Gamefic::Plot.new.tap do |plot|
        player = plot.make_player_character
        plot.introduce player
        plot.ready
        plot.branch Gamefic::Subplot, introduce: player
      end
    end

    let(:restored) { Gamefic::Plot.restore plot.save }

    it 'restores players' do
      player = restored.players.first
      expect(player.playbooks).to eq([restored.playbook, restored.subplots.first.playbook])
      expect(player.scenebooks).to eq([restored.scenebook, restored.subplots.first.scenebook])
    end

    it 'restores subplots' do
      expect(restored.subplots).to be_one
    end

    it 'restores stage instance variables' do
      thing = restored.stage { @thing }
      expect(thing.name).to eq('thing')
      picked = restored.pick('thing')
      expect(thing).to be(picked)
    end

    it 'restores references in actions' do
      player = restored.players.first
      player.cue :default_scene
      restored.ready
      player.perform 'look thing'
      puts player.messages.inspect
      player.perform 'think'
      puts player.messages.inspect
    end
  end
end
