# frozen_string_literal: true

describe Gamefic::Delegatable::Sessions do
  let(:plot) do
    Gamefic.script do
      session[:test] = 'saved'
    end

    Gamefic::Plot.new
  end

  it 'stores data' do
    expect(plot.session[:test]).to eq('saved')
  end

  it 'restores data' do
    snapshot = plot.save
    restored = Gamefic::Plot.restore(snapshot)
    expect(restored.session[:test]).to eq('saved')
  end
end
