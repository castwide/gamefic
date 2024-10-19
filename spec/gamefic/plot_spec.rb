# frozen_string_literal: true

RSpec.describe Gamefic::Plot do
  it 'creates responses' do
    klass = Class.new(Gamefic::Plot) do
      respond :command do |_actor|
        nil
      end
    end
    plot = klass.new
    expect(plot.responses).to be_one
  end

  it 'cues the introduction' do
    klass = Class.new(Gamefic::Plot) do
      introduction do |actor|
        actor.tell 'Hello, world!'
      end
    end
    plot = klass.new
    player = plot.introduce
    expect(player.messages).to include('Hello, world!')
  end

  it 'tracks player subplots' do
    plot = Gamefic::Plot.new
    player = plot.introduce
    subplot = plot.branch Gamefic::Subplot, introduce: player
    expect(player.narratives.to_a).to eq([plot, subplot])
  end

  it 'deletes concluded subplots on turns' do
    plot = Gamefic::Plot.new
    subplot = plot.branch Gamefic::Subplot
    expect(plot.subplots).to include(subplot)
    subplot.conclude
    plot.turn
    expect(plot.subplots).to be_empty
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
    Gamefic::Narrator::Take.new(actor, plot.default_scene).start
    plot.turn
    expect(plot.subplots).to be_empty
    expect(actor.narratives).to be_one
  end
end
