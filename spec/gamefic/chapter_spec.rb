# frozen_string_literal: true

describe Gamefic::Chapter do
  it 'does not duplicate plot script features' do
    scriptable = Module.new do
      include Gamefic::Scripting

      introduction { |actor| actor[:ready_count] = 0 }
      on_player_ready { |actor| actor[:ready_count] += 1 }
    end

    chapter_klass = Class.new(Gamefic::Chapter) do
      include scriptable
    end

    plot_klass = Class.new(Gamefic::Plot) do
      include scriptable
      append chapter_klass
    end

    plot = plot_klass.new
    actor = plot.introduce
    plot.ready
    expect(actor[:ready_count]).to eq(1)
  end

  it 'binds methods from plots' do
    chapter_klass = Class.new(Gamefic::Chapter) do
      bind_from_plot :thing
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chapter_klass

      construct :thing, Gamefic::Entity, name: 'thing'
    end

    plot = plot_klass.new
    expect(plot.chapters.first.thing).to be(plot.thing)
  end
end
