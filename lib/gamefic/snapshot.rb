# frozen_string_literal: true

require 'corelib/marshal' if RUBY_ENGINE == 'opal'

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

    def self.digest plot
      binary = {
        entities: plot.entities.map(&:inspect),
        theater: plot.instance_variable_get(:@theater).instance_variables.map do |iv|
          [iv, plot.instance_variable_get(:@theater).instance_variable_get(iv).class]
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
            theater: plot.instance_variable_get(:@theater),
            delegator: plot.instance_variable_get(:@delegator)
          },
          subplots: collect_subplots(plot.subplots)
        }
      end

      def collect_subplots subplots
        subplots.map do |sp|
          {
            klass: sp.class.to_s, uuid: sp.uuid, config: sp.config,
            entities: sp.entities, players: sp.players,
            theater: sp.instance_variable_get(:@theater),
            delegator: sp.instance_variable_get(:@delegator)
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
        part = rebuild_common(data)
        part.run_scripts
        raise LoadError, 'Incompatible snapshot' unless part.digest == data[:digest]

        part.instance_variable_set(:@entities, data[:entities])
        part.instance_variable_set(:@players, data[:players])
        part.instance_variable_set(:@theater, data[:theater])
        rebuild_players part
        part
      end

      def rebuild_subplot data, plot
        part = rebuild_common(data)
        part.instance_variable_set(:@host, plot)
        part.instance_variable_set(:@config, data[:config])
        part.configure(**data[:config])
        part.run_scripts

        part.instance_variable_set(:@uuid, data[:uuid])
        part.instance_variable_set(:@entities, data[:entities])
        part.instance_variable_set(:@players, data[:players])
        part.instance_variable_set(:@theater, data[:theater])
        rebuild_players part
        part
      end

      def rebuild_common data
        klass = string_to_constant(data[:klass])
        part = klass.allocate
        part.instance_variable_set(:@delegator, data[:delegator])
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
        result
      end
    end
  end
end
