# frozen_string_literal: true

describe Gamefic::Query::Parent do
  it 'finds a parent' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent
    result = Gamefic::Query::Parent.new.span(context)
    expect(result).to eq([parent])
  end

  it 'returns an empty array without a parent' do
    context = Gamefic::Entity.new
    result = Gamefic::Query::Parent.new.span(context)
    expect(result).to eq([])
  end
end