# frozen_string_literal: true

require 'set'

module Gamefic
  module Binding
    module Bindable
      module ClassMethods
        def bind *methods
          bound_methods.merge(methods)
        end

        def bound_methods
          @bound_methods ||= Set.new
        end
      end

      def bound_methods
        self.class.bound_methods.to_a
      end
    end
  end
end
