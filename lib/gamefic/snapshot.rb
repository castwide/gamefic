# frozen_string_literal: true

# require 'corelib/marshal' if RUBY_ENGINE == 'opal'
require 'base64'

module Gamefic
  # Save and restore plots.
  #
  module Snapshot
    # Save a base64-encoded snapshot of a plot.
    #
    # @param plot [Plot]
    # @return [String]
    def self.save plot
      plot.instance_variable_set(:@takes, nil)
      binary = Marshal.dump(plot)
      Base64.encode64(binary)
    end

    # Restore a plot from a base64-encoded string.
    #
    # @param snapshot [String]
    # @return [Plot]
    def self.restore snapshot
      binary = Base64.decode64(snapshot)
      Marshal.load(binary).tap do |plot|
        ([plot] + plot.subplots).each do |part|
          part.run_scripts
          part.theater.freeze
          part.entity_vault.array.freeze
          part.player_vault.array.freeze
        end
      end
    end

    # Generate a digest of a narrative.
    #
    # Digests are used to validate snapshots. If a snapshot's digest does not
    # match the digest of its allocated class, the snapshot cannot be restored.
    #
    # @param narrative [Narrative]
    def self.digest narrative
      binary = {
        entities: narrative.entities[0, narrative.entity_vault.lock].map(&:class),
        theater: narrative.theater.instance_metadata
      }.inspect
      calculate_digest binary
    end

    class << self
      private

      def calculate_digest binary
        # @todo This is a cheesy digest, but it should work well enough for
        #   this purpose as long as the number is small enough and collisions
        #   are acceptably rare.
        result = 0
        multiplier = 1

        binary.bytes.each_slice(64) do |slice|
          result += slice.map.with_index { |byte, idx| byte * (255 ^ idx) }
                         .sum + (multiplier * 64 * 255)
          multiplier += 1
        end
        result.to_s(16)
      end
    end
  end
end
