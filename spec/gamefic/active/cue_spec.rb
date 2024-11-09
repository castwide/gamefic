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
end
