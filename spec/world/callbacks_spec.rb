describe Gamefic::World::Callbacks do
  it 'runs on_ready blocks' do
    plot = Gamefic::Plot.new
    plot.stage do
      @executed = false
      on_ready do
        @executed = true
      end
    end
    plot.ready
    result = plot.stage { @executed }
    expect(result).to be(true)
  end

  it 'runs on_update blocks' do
    plot = Gamefic::Plot.new
    plot.stage do
      @executed = false
      on_update do
        @executed = true
      end
    end
    plot.update
    result = plot.stage { @executed }
    expect(result).to be(true)
  end

  it 'runs on_player_ready blocks' do
    plot = Gamefic::Plot.new
    plot.stage do
      @executed = false
      on_player_ready do |player|
        player[:executed] = true
      end
    end
    actor = plot.get_player_character
    plot.introduce actor
    plot.ready
    expect(actor[:executed]).to be(true)
  end

  it 'runs on_player_update blocks' do
    plot = Gamefic::Plot.new
    plot.stage do
      @executed = false
      on_player_update do |player|
        player[:executed] = true
      end
    end
    actor = plot.get_player_character
    plot.introduce actor
    plot.update
    expect(actor[:executed]).to be(true)
  end

  it 'runs before_player_update blocks' do
    plot = Gamefic::Plot.new
    plot.stage do
      @executed = false
      before_player_update do |player|
        player[:executed] = true
      end
    end
    actor = plot.get_player_character
    plot.introduce actor
    plot.update
    expect(actor[:executed]).to be(true)
  end
end
