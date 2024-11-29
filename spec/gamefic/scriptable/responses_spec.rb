# frozen_string_literal: true

describe Gamefic::Scriptable::Responses do
  let(:object) { Object.new.extend(Gamefic::Scriptable) }

  it 'saves a response' do
    object.respond :verb
    expect(object.responses).to be_one
    expect(object.responses.first.verb).to eq(:verb)
  end

  it 'handles unicode verbs' do
    response = object.respond(:'ꩺ')
    available = object.responses_for(:'ꩺ')
    expect(available).to eq([response])
  end

  it 'converts strings to symbols' do
    response = object.respond('ꩺ')
    available = object.responses_for('ꩺ')
    expect(available).to eq([response])
  end
end
