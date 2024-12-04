# frozen_string_literal: true

describe Gamefic::Scene::Base do
  let(:actor) { Gamefic::Actor.new }

  let(:base) { Gamefic::Scene::Base.new(actor) }

  it 'initializes Base props' do
    expect(base.props).to be_a(Gamefic::Props::Default)
  end

  describe '#start' do
    it 'returns props' do
      expect(base.start).to be(base.props)
    end
  end
end
