describe Gamefic::Plot::Snapshot do
  after :each do
    Gamefic::Plot.blocks.clear
    GC.start
  end

  it "saves entities" do
    plot = Gamefic::Plot.new
    plot.make Gamefic::Entity, name: 'entity'
    snapshot = plot.save
    plot.restore(snapshot)
    expect(plot.entities).to be_one
  end

  it "restores dynamic entities" do
    plot = Gamefic::Plot.new
    entity = plot.make Gamefic::Entity, name: 'old name'
    snapshot = plot.save
    entity.name = 'new name'
    plot.restore snapshot
    restored = plot.entities.first
    expect(restored.name).to eq('old name')
  end

  it "saves subplots" do
    plot = Gamefic::Plot.new
    plot.branch Gamefic::Subplot
    snapshot = plot.save
    expect(snapshot[0]['ivars']['@subplots'].length).to eq(1)
  end

  it "restores subplots" do
    plot = Gamefic::Plot.new
    subplot = plot.branch Gamefic::Subplot
    snapshot = plot.save
    subplot.conclude
    expect(subplot.concluded?).to be(true)
    plot.restore snapshot
    expect(plot.subplots.length).to eq(1)
    expect(plot.subplots[0].concluded?).to be(false)
  end

  it "restores dynamic entities" do
    plot = Gamefic::Plot.new
    plot.make Gamefic::Entity, name: 'static entity'
    plot.ready
    plot.make Gamefic::Entity, name: 'dynamic entity'
    snapshot = plot.save
    plot.restore snapshot
    expect(plot.entities.length).to eq(2)
    expect(plot.entities[1].name).to eq('dynamic entity')
  end

  it "restores a player" do
    plot = Gamefic::Plot.new
    player = plot.cast Gamefic::Actor, name: 'old name'
    plot.introduce player
    snapshot = plot.save
    player.name = 'new name'
    plot.restore snapshot
    expect(plot.entities.length).to eq(1)
    expect(plot.entities[0].name).to eq('old name')
  end

  it "restores a hash in an entity session" do
    plot = Gamefic::Plot.new
    entity = plot.make Gamefic::Entity, name: 'entity'
    hash = { one: 'one', two: 'two' }
    entity[:hash] = hash
    snapshot = plot.save
    entity[:hash] = nil
    plot.restore snapshot
    expect(plot.entities.first[:hash]).to eq(hash)
  end

  it 'restores a static entity in place' do
    Gamefic.script do
      @entity = make Gamefic::Entity, name: 'old name'
    end
    plot = Gamefic::Plot.new
    Gamefic::Plot.blocks.pop
    snapshot = plot.save
    entity = plot.stage { @entity }
    plot.stage do
      @entity.name = 'new name'
    end
    expect(entity.name).to eq('new name')
    plot.restore snapshot
    expect(entity).to be(plot.entities.first)
    expect(entity.name).to eq('old name')
  end

  it 'restores scenes' do
    Gamefic.script do
      @pause_scene = pause do |actor, scene|
        actor.tell "pause"
        actor.prepare default_scene
      end

      introduction do |actor|
        actor.cue @pause_scene
      end
    end
    plot = Gamefic::Plot.new
    pause_scene = plot.stage { @pause_scene }
    actor = plot.get_player_character
    plot.introduce actor
    snapshot = plot.save
    # plot.restore snapshot
    # plot.ready
    expect(plot.players.first.scene.class).to eq(pause_scene)
  end

  it 'restores subplots' do
    Gamefic.script do
      @next_scene = pause do |actor|
        actor.tell "Done!"
        actor.prepare default_scene
      end

      introduction do |actor|
        branch Gamefic::Subplot, introduce: actor, next_cue: @next_scene
      end
    end
    plot = Gamefic::Plot.new
    next_scene = plot.stage { @next_scene }
    actor = plot.get_player_character
    plot.introduce actor
    snapshot = plot.save
    plot.subplots_featuring(actor).first.conclude
    expect(plot.subplots_featuring(actor)).to be_empty
    plot.restore snapshot
    plot.ready
    expect(plot.subplots_featuring(actor)).to be_one
    subplot = plot.subplots.first
    next_cue = subplot.instance_variable_get(:@next_cue)
    expect(next_cue).to be(next_scene)
  end

  it 'restores scene classes' do
    Gamefic.script do
      @pause_scene = pause do |actor|
        actor.tell "Done!"
        actor.prepare default_scene
      end
    end
    plot = Gamefic::Plot.new
    saved_scene = plot.stage { @pause_scene }
    snapshot = plot.save
    plot.stage { @pause_scene = nil }
    nil_scene = plot.stage { @pause_scene }
    expect(saved_scene).not_to be(nil_scene)
    plot.restore snapshot
    restored_scene = plot.stage { @pause_scene }
    expect(saved_scene).to be(restored_scene)
  end

  it 'restores stage instance variables' do
    Gamefic.script do
      @entity = make Gamefic::Entity, name: 'old'
    end

    plot = Gamefic::Plot.new
    snapshot = plot.save
    plot.stage { @entity.name = 'new' }
    expect(plot.stage { @entity.name }).to eq('new')
    plot.restore snapshot
    expect(plot.stage { @entity.name }).to eq('old')
  end
end
