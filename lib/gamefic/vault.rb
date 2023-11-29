module Gamefic
  # An array wrapper that exposes a protected interface.
  #
  class Vault
    attr_reader :array

    def initialize
      @array = [].freeze
    end

    def add object
      @array = (@array.clone + [object]).freeze
      object
    end

    def delete object
      return false unless deletable?(object)

      @array = (@array.dup - [object]).freeze
    end

    def lock
      raise "Vault is already locked" if @lock_index

      @lock_index = @array.length
    end

    def deletable? object
      @lock_index.to_i <= @array.find_index(object).to_i
    end
  end
end
