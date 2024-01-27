# frozen_string_literal: true

describe Gamefic::Scope::Myself do
  it 'finds itself' do
    context = Gamefic::Entity.new
    myself = Gamefic::Scope::Myself.matches(context)
    expect(myself).to eq([context])
  end
end
