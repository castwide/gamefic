# frozen_string_literal: true

describe Gamefic::Query::Siblings do
  it 'finds siblings' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent
    result = Gamefic::Query::Siblings.new.span(context)
    expect(result).to eq([sibling])
  end
end
