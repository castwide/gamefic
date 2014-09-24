
module Snapshot
  module Subject
    attr_reader :snapshot_key
    @@snapshot_key_index = 0
    # TODO: See comment in Entity below
    # TODO #2: While implementing standard tests, I noticed that alias_method calls
    # from imported scripts can explode the stack.
    alias_method :snapshot_subject_orig_post_initialize, :post_initialize
    def post_initialize
      snapshot_subject_orig_post_initialize
      # TODO: Dynamically generated entities should use a different key signature
      @snapshot_key = "static_entity_#{@@snapshot_key_index}"
      @@snapshot_key_index += 1
    end
  end
end

class Entity
    # TODO: We could use a prepend here if we didn't need to support Ruby 1.9.3
    include Snapshot::Subject
end
