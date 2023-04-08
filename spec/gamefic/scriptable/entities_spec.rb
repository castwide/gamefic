# frozen_string_literal: true

describe Gamefic::Scriptable::Entities do
  let(:object) {
    Object.new.tap do |obj|
      obj.extend Gamefic::Scriptable::Entities
    end
  }
end
