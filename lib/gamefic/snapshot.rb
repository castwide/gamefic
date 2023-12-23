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
  end
end
