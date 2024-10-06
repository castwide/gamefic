# frozen_string_literal: true

describe Gamefic::Query::Myself do
  it 'finds itself' do
    context = Gamefic::Entity.new
    myself = Gamefic::Query::Myself.new.span(context)
    expect(myself).to eq([context])
  end
end
