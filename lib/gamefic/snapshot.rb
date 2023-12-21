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
      plot.uncast_all
      snapshot = collect(plot)
      binary = Marshal.dump(snapshot)
      plot.cast_all
      Base64.encode64(binary)
    end

    # Restore a plot from a base64-encoded string.
    #
    # @param snapshot [String]
    # @return [Plot]
    def self.restore snapshot
      data = decode_and_load(snapshot)
      rebuild_all(data)
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

      def collect plot
        {
          plot: {
            digest: plot.digest, klass: plot.class.to_s,
            entity_vault: plot.entity_vault, player_vault: plot.player_vault,
            theater: plot.theater, session: plot.session
          },
          subplots: collect_subplots(plot.subplots)
        }
      end

      def collect_subplots subplots
        subplots.map do |sp|
          {
            klass: sp.class.to_s, uuid: sp.uuid, config: sp.config,
            entity_vault: sp.entity_vault, player_vault: sp.player_vault, theater: sp.theater,
            session: sp.session
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

      def decode_and_load snapshot
        Marshal.load(Base64.decode64(snapshot))
      end

      def rebuild_all data
        plot = rebuild_plot(data[:plot])
        data[:subplots].each { |subdata| rebuild_subplot(subdata, plot) }
        plot.players.each(&:recue)
        plot
      end

      def rebuild_plot data
        part = allocate_object(data[:klass])
        rebuild_world_model data, part
        raise LoadError, 'Incompatible snapshot' unless part.digest == data[:digest]

        finish_build part
        part
      end

      def rebuild_subplot data, plot
        part = allocate_object(data[:klass])
        part.instance_variable_set(:@plot, plot)
        %i[config uuid].each { |key| part.instance_variable_set("@#{key}", data[key]) }
        part.configure
        part.config.freeze
        rebuild_world_model data, part

        finish_build part
        plot.subplots.push part
        part
      end

      def allocate_object klass
        string_to_constant(klass).allocate
      end

      def rebuild_world_model data, part
        %i[entity_vault player_vault theater session].each { |key| part.instance_variable_set("@#{key}", data[key]) }
        [part.entity_vault.array, part.player_vault.array].each(&:freeze)
        part.set_seeds
      end

      def finish_build part
        part.run_scripts
        part.set_rules
        part.players.each do |plyr|
          plyr.rulebooks.add part.rulebook
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
