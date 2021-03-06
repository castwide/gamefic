require "gamefic"

describe Gamefic::Plot do
  it "accepts new entities" do
    plot = Gamefic::Plot.new
    plot.make Gamefic::Entity
    expect(plot.entities.length).to eq(1)
  end

  it "accepts new actions" do
    plot = Gamefic::Plot.new
    plot.respond :mycommand do |actor|
    end
    expect(plot.playbook.actions_for(:mycommand).length).to eq(1)
  end

  it "adds new actions to the list of command words" do
    plot = Gamefic::Plot.new
    plot.respond :mycommand do |actor|
      actor.tell "myresult"
    end
    expect(plot.verbs.include?("mycommand")).to be true
  end

  it "removes destroyed dynamic entities" do
    plot = Gamefic::Plot.new
    plot.ready
    entity = plot.make Gamefic::Entity
    plot.destroy entity
    expect(plot.entities.length).to eq(0)
  end

  it "adds playbook to casted actors" do
    plot = Gamefic::Plot.new
    actor = plot.cast Gamefic::Actor
    expect(actor.playbooks.length).to eq(1)
    expect(actor.playbooks[0]).to eq(plot.playbook)
  end

  it "tracks player subplots" do
    plot = Gamefic::Plot.new
    actor = plot.cast Gamefic::Actor
    plot.branch Gamefic::Subplot, introduce: actor
    expect(plot.subplots_featuring(actor)).not_to be_empty
    expect(plot.in_subplot?(actor)).to be(true)
  end

  it 'deletes concluded subplots on update' do
    plot = Gamefic::Plot.new
    subplot = plot.branch Gamefic::Subplot
    expect(plot.subplots).to include(subplot)
    subplot.conclude
    plot.update
    expect(plot.subplots).to be_empty
  end

  it "pauses on a pause scene" do
    plot = Gamefic::Plot.new
    actor = plot.cast Gamefic::Actor
    plot.stage do
      @pause = pause do |actor|
        actor.tell "Paused"
      end
      introduction do |actor|
        actor.cue @pause
      end
    end
    plot.introduce actor
    plot.ready
    expect(actor.scene.type).to eq('Pause')
  end

  it 'runs conclude procs' do
    plot = Gamefic::Plot.new
    actor = plot.cast Gamefic::Actor
    ran = false
    plot.stage do
      on_player_conclude do |player|
        ran = true
      end
    end
    plot.introduce actor
    plot.ready
    actor.cue plot.default_conclusion
    plot.update
    expect(ran).to be true
  end
end
