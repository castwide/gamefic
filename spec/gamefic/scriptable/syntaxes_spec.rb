# frozen_string_literal: true

describe Gamefic::Scriptable::Syntaxes do
  it 'splits piped verbs' do
    object = Object.new.extend Gamefic::Scriptable::Syntaxes
    syntaxes = object.interpret('move|walk :somewhere', 'go :somewhere')
    expect(syntaxes.count).to eq(2)
    expect(syntaxes.map(&:template)).to eq(['move :somewhere', 'walk :somewhere'])
    expect(syntaxes.map(&:command)).to eq(['go :somewhere', 'go :somewhere'])
  end
end
