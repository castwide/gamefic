# frozen_string_literal: true

describe Gamefic::Scriptable::Entities do
  let(:object) {
    Object.new.tap do |obj|
      obj.extend Gamefic::Scriptable::Entities
      # @todo Module expects #setup to exist. Is there a better way to do this?
      obj.define_singleton_method(:setup) { Gamefic::Setup.new }
    end
  }
end
