module Gamefic
  # An array wrapper that exposes a protected interface. The array is always
  # returned frozen. It can only be modified through #add and #delete. The
  # vault can be "locked" to prevent existing elements from being deleted.
  #
  class Vault
    def initialize
      @set = Set.new
      @array = []
    end

    # @return [Array]
    def array
      @array.freeze
    end

    # @param object [Object]
    def add object
      @array = @set.add(object).to_a
      object
    end

    # @param object [Object]
    # @return [Boolean] True if object was deleted
    def delete object
      return false unless deletable?(object) && @set.delete?(object)

      @array = @set.to_a.freeze
      true
    end

    # Lock the current elements in the vault.
    #
    # After the vault is locked, calling #delete on a locked element will leave
    # the element in the array and return false. Elements added after the lock
    # can be deleted.
    #
    def lock
      return @lock_index if @lock_index

      @lock_index = @array.length
    end

    # @return [Boolean] True if the object is deletable (i.e., not locked).
    def deletable? object
      @lock_index.to_i <= @array.find_index(object).to_i
    end
  end
end
