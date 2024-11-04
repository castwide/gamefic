# frozen_string_literal: true

describe Gamefic::Query::Extended do
  it 'finds siblings and their descendants' do
    parent = Gamefic::Entity.new
    context = Gamefic::Entity.new parent: parent
    sibling = Gamefic::Entity.new parent: parent
    nephew = Gamefic::Entity.new parent: sibling
    result = Gamefic::Query::Extended.new.span(context)
    expect(result).to eq([sibling, nephew])
  end
end
