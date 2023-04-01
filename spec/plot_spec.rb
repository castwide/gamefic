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

  # it 'concludes on conclusions' do
  #   plot = Gamefic::Plot.new
  #   player = plot.make_player_character
  #   plot.introduce player
  #   plot.ready
  #   player.cue plot.default_conclusion
  #   expect(player).to be_concluding
  # end

  # it "removes destroyed dynamic entities" do
  #   plot = Gamefic::Plot.new
  #   plot.ready
  #   entity = plot.make Gamefic::Entity
  #   plot.destroy entity
  #   expect(plot.entities.length).to eq(0)
  # end

  # it "adds playbook to casted actors" do
  #   plot = Gamefic::Plot.new
  #   actor = plot.cast Gamefic::Actor
  #   expect(actor.playbooks.length).to eq(1)
  #   expect(actor.playbooks[0]).to eq(plot.playbook)
  # end

  # it 'supports multiple players' do
  #   plot = Gamefic::Plot.new
  #   player1 = plot.make_player_character
  #   plot.introduce player1
  #   player2 = plot.make_player_character
  #   plot.introduce player2
  #   expect(plot.players).to eq([player1, player2])
  # end

  # it 'cancels actions in before_action hooks' do
  #   plot = Gamefic::Plot.new
  #   plot.respond :command do |actor|
  #     actor.tell 'executed'
  #   end
  #   plot.before_action do |action|
  #     if action.verb == :command
  #       action.actor.tell 'cancelled'
  #       action.cancel
  #     end
  #   end
  #   player = plot.make_player_character
  #   plot.introduce player
  #   player.perform 'command'
  #   expect(player.messages).to include('cancelled')
  #   expect(player.messages).not_to include('executed')
  # end

  # it 'executes after actions' do
  #   plot = Gamefic::Plot.new
  #   plot.respond :command, Gamefic::Query::Text.new do |actor, _text|
  #     actor.tell 'during'
  #   end
  #   plot.after_action do |action|
  #     if action.verb == :command
  #       action.actor.tell "afterwards with args #{action.arguments}.join_and"
  #     end
  #   end
  #   player = plot.make_player_character
  #   plot.introduce player
  #   player.perform 'command 1 2 3'
  #   expect(player.messages).to include('during')
  #   expect(player.messages).to include('afterwards')
  #   expect(player.messages).to include('1 2 3')
  # end

  # it 'filters before and after actions by verb' do
  #   plot = Gamefic::Plot.new
  #   plot.respond :command do |actor|
  #     actor.tell 'during'
  #   end
  #   plot.before_action(:command) { |action| action.actor.tell 'right_before' }
  #   plot.after_action(:command) { |action| action.actor.tell 'right_after' }
  #   plot.before_action(:do_not_run) { |action| action.actor.tell 'wrong_before' }
  #   plot.after_action(:do_not_run) { |action| action.actor.tell 'wrong_after' }

  #   player = plot.make_player_character
  #   plot.introduce player
  #   player.perform 'command'

  #   expect(player.messages).to include('right_before')
  #   expect(player.messages).to include('during')
  #   expect(player.messages).to include('right_after')
  #   expect(player.messages).not_to include('wrong_before')
  #   expect(player.messages).not_to include('wrong_after')
  # end
end
