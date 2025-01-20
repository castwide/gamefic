# frozen_string_literal: true

RSpec.describe Gamefic::Active::Cue do
  it 'cues a named scene' do
    klass = Class.new(Gamefic::Narrative) do
      pause(:pause_scene) {}
    end
    plot = klass.new
    player = plot.introduce
    cue = Gamefic::Active::Cue.new(player, :pause_scene, plot)
    cue.start
    expect(cue.scene.name).to eq('pause_scene')
  end

  it 'cues a scene class' do
    scene_class = Class.new(Gamefic::Scene::Base) do
      rename 'my_scene'
    end
    player = Gamefic::Actor.new
    cue = Gamefic::Active::Cue.new(player, scene_class, nil)
    expect(cue.scene.name).to eq('my_scene')
  end
end
