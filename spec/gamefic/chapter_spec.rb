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
end
