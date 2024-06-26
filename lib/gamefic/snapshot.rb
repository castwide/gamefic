# frozen_string_literal: true

require 'corelib/marshal' if RUBY_ENGINE == 'opal' # Required in browser
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
      cache = plot.detach
      binary = Marshal.dump(plot)
      plot.attach cache
      Base64.encode64(binary)
    end

    # Restore a plot from a base64-encoded string.
    #
    # @param snapshot [String]
    # @return [Plot]
    def self.restore snapshot
      binary = Base64.decode64(snapshot)
      Marshal.load(binary).tap do |plot|
        plot.hydrate
        # @todo Opal marshal dumps are not idempotent
        next if RUBY_ENGINE == 'opal' || match?(plot, snapshot)

        Logging.logger.warn "Scripts modified #{plot.class} data. Snapshot may not have restored properly"
      end
    end

    # True if the plot's state matches the snapshot.
    #
    # @param plot [Plot]
    # @param snapshot [String]
    def self.match?(plot, snapshot)
      save(plot) == snapshot
    end
  end
end
