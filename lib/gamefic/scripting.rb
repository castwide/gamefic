# frozen_string_literal: true

module Gamefic
  # An instance module that enables scripting.
  #
  # Including `Gamefic::Scripting` also extend `Gamefic::Scriptable`.
  #
  module Scripting
    def bound_methods
      self.class.bound_methods.to_a
    end

    def bound? method
      self.class.bound_methods.include?(method)
    end

    def self.included other
      super
      other.extend Scriptable
    end
  end
end
