# frozen_string_literal: true

require 'corelib/marshal' if RUBY_ENGINE == 'opal' # Required in browser
require 'base64'

module Gamefic
  # Save and restore plots.
  #
  module Snapshot
    # Save a binary snapshot of a plot.
    #
    # @param plot [Plot]
    # @return [String]
    def self.save(plot)
      Marshal.dump(plot)
    end

    # Restore a plot from a binary string.
    #
    # @param snapshot [String]
    # @return [Plot]
    def self.restore(snapshot)
      Marshal.load(snapshot)
    end
  end
end
