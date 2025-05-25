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

  it 'appends responses from chapters' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      respond(:chapter) {}
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass
    end

    plot = plot_klass.new
    expect(plot.responses_for(:chapter)).to be_one
  end

  it 'appends default syntaxes from chapters' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      respond(:chapter) {}
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass

      respond(:other) {}
    end

    plot = plot_klass.new
    expect(plot.syntaxes.map(&:synonym)).to include(:chapter)
  end

  it 'executes responses from chapters' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      respond(:chapter) { |actor| actor[:executed] = true }
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass
    end

    plot = plot_klass.new
    actor = plot.introduce
    actor.perform 'chapter'
    expect(actor[:executed]).to be(true)
  end

  it 'binds ready blocks from chapters' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      on_player_ready do |player|
        player[:executed] = true
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass
    end

    plot = plot_klass.new
    player = plot.introduce
    ready_blocks = plot.ready_blocks
    expect(ready_blocks).to be_one
    ready_blocks.each { |blk| blk[player] }
    expect(player[:executed]).to be(true)
  end

  it 'deletes concluded chapters on turns' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      respond(:conclude, 'me') { conclude }
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass
    end

    plot = plot_klass.new
    player = plot.introduce
    player.perform 'conclude me'
    plot.turn
    expect(plot.chapters).to be_empty
  end

  context 'with a scriptable module' do
    require_relative '../fixtures/modular/modular_test_plot'

    let(:plot) { ModularTestPlot.new }
    let(:player) { plot.introduce }

    it 'creates entities from the module' do
      expect(plot.place).to be_a(Gamefic::Entity)
      expect(plot.thing).to be_a(Gamefic::Entity)
    end

    it 'sets parents of module entities correctly' do
      expect(plot.thing.parent).to be(plot.place)
      expect(player.parent).to be(plot.place)
    end

    it 'responds to commands with module entity arguments' do
      player.perform 'use thing'
      expect(player[:used]).to be(plot.thing)
    end

    it 'seeds unreferenced entities' do
      expect(plot.instance_variable_get(:@unreferenced)).to be_a(Gamefic::Entity)
    end
  end
end
