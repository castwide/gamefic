module Gamefic
  # An array wrapper that exposes a protected interface. The array is always
  # returned frozen. It can only be modified through #add and #delete. The
  # vault can be "locked" to prevent existing elements from being deleted.
  #
  class Vault
    # @return [Array]
    attr_reader :array

    def initialize
      @array = [].freeze
    end

    # @param object [Object]
    def add object
      return object if @array.include?(object)

      @array = (@array.clone + [object]).freeze
      object
    end

    # @param object [Object]
    # @return [Boolean] True if object was deleted
    def delete object
      return false unless deletable?(object)

      @array = (@array.dup - [object]).freeze
      true
    end

    # Lock the current elements in the vault.
    #
    # After the vault is locked, calling #delete on a locked element will leave
    # the element in the array and return false. Elements added after the lock
    # can be deleted.
    #
    def lock
      raise 'Vault is already locked' if @lock_index

      @lock_index = @array.length
    end

    # @return [Boolean] True if the object is deletable (i.e., not locked).
    def deletable? object
      @lock_index.to_i <= @array.find_index(object).to_i
    end
  end
end
