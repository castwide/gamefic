# frozen_string_literal: true

require 'corelib/marshal' if RUBY_ENGINE == 'opal'
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
      plot.players.each do |plyr|
        plyr.scenebooks.clear
        plyr.playbooks.clear
      end
      snapshot = collect(plot)
      binary = Marshal.dump(snapshot)
      plot.players.each { |plyr| plot.cast(plyr) }
      plot.subplots.each { |sp| sp.players.each { |plyr| sp.cast plyr } }
      Base64.encode64(binary)
    end

    # Restore a plot from a base64-encoded string.
    #
    # @param snapshot [String]
    # @return [Plot]
    def self.restore snapshot
      binary = Base64.decode64(snapshot)
      data = Marshal.load(binary)
      plot = rebuild_plot(data[:plot])
      data[:subplots].each do |subdata|
        subplot = rebuild_subplot(subdata, plot)
        plot.subplots.push subplot
      end
      plot.players.each(&:recue)
      plot
    end

    # Generate a digest of a narrative.
    #
    # Digests are used to validate snapshots. If a snapshot's digest does not
    # match the digest of its allocated class, the snapshot cannot be restored.
    #
    # @note A narrative's digest can change during its runtime, so the digest
    #   in the snapshot should be the value that was calculated during
    #   initialization.
    #
    # @param narrative [Narrative]
    def self.digest narrative
      binary = {
        entities: narrative.entities.map(&:inspect),
        theater: narrative.instance_variable_get(:@theater).instance_variables.map do |iv|
          [iv, narrative.instance_variable_get(:@theater).instance_variable_get(iv).class]
        end
      }.inspect
      calculate_digest binary
    end

    class << self
      private

      def collect plot
        {
          plot: {
            digest: plot.digest, klass: plot.class.to_s,
            entities: plot.entities, players: plot.players,
            theater: plot.instance_variable_get(:@theater)
          },
          subplots: collect_subplots(plot.subplots)
        }
      end

      def collect_subplots subplots
        subplots.map do |sp|
          {
            klass: sp.class.to_s, uuid: sp.uuid, config: sp.config,
            entities: sp.entities, players: sp.players,
            theater: sp.instance_variable_get(:@theater)
          }
        end
      end

      def string_to_constant string
        space = Object
        string.split('::').each do |part|
          space = space.const_get(part)
        end
        space
      end

      def rebuild_plot data
        part = string_to_constant(data[:klass]).allocate
        part.run_scripts
        part.set_static
        raise LoadError, 'Incompatible snapshot' unless part.digest == data[:digest]

        %i[entities players theater].each { |key| part.instance_variable_set("@#{key}", data[key]) }
        rebuild_players part
        part
      end

      def rebuild_subplot data, plot
        part = string_to_constant(data[:klass]).allocate
        part.instance_variable_set(:@host, plot)
        part.instance_variable_set(:@config, data[:config])
        part.configure
        part.run_scripts
        part.set_static

        %i[uuid entities players theater].each { |key| part.instance_variable_set("@#{key}", data[key]) }
        rebuild_players part
        part
      end

      def rebuild_players part
        part.players.each do |plyr|
          plyr.playbooks.add part.playbook
          plyr.scenebooks.add part.scenebook
        end
      end

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
