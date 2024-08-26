# frozen_string_literal: true

describe Gamefic::Chapter do
  it 'seeds entities on its narrative' do
    chap_klass = Class.new(Gamefic::Chapter) do
      seed do
        @thing = make Gamefic::Entity, name: 'thing'
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass
    end

    plot = plot_klass.new
    expect(plot.entities.map(&:name)).to eq(['thing'])
    expect(plot.chapters.first.instance_eval { @thing }).to be(plot.entities.first)
  end

  it 'creates responses in the narrative rulebook' do
    chap_klass = Class.new(Gamefic::Chapter) do
      script do
        respond(:chapter) {}
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass
    end

    plot = plot_klass.new
    expect(plot.rulebook.verbs).to eq([:chapter])
  end

  it 'uses its own variable space' do
    target = nil

    chap_klass = Class.new(Gamefic::Chapter) do
      seed do
        @this_one = 'chap_klass'
      end

      script do
        respond(:target) { target = @this_one }
      end
    end

    plot_klass = Class.new(Gamefic::Plot) do
      append chap_klass

      seed do
        @this_one = 'plot_klass'
      end
    end

    plot = plot_klass.new
    player = plot.introduce
    player.perform 'target'
    expect(target).to eq('chap_klass')
  end
end
