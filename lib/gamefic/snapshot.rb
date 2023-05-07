require 'corelib/marshal' if RUBY_ENGINE == 'opal'
# require 'zlib'

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
        plyr.playbooks.clear
        plyr.scenebooks.clear
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
      plot = rebuild(data[:plot])
      data[:subplots].each do |subdata|
        subplot = rebuild(subdata)
        plot.subplots.push subplot
      end
      plot.players.each(&:recue)
      plot
    end

    def self.digest plot
      binary = Marshal.dump({
        entities: plot.entities,
        theater: plot.instance_variable_get(:@theater)
      })
      calculate_digest binary
    end

    class << self
      private

      def collect plot
        {
          plot: {
            digest: plot.digest,
            klass: plot.class.to_s,
            entities: plot.entities,
            players: plot.players,
            theater: plot.instance_variable_get(:@theater),
            delegator: plot.instance_variable_get(:@delegator)
          },
          subplots: plot.respond_to?(:subplots) ? collect_subplots(plot.subplots) : []
        }
      end

      def collect_subplots subplots
        subplots.map do |sp|
          {
            klass: sp.class.to_s,
            digest: sp.digest,
            config: sp.config,
            entities: sp.entities,
            players: sp.players,
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

      def rebuild data
        klass = string_to_constant(data[:klass])
        part = klass.allocate
        part.instance_variable_set(:@delegator, data[:delegator])
        part.instance_variable_set(:@config, data[:config]) if data[:config]
        part.run_scripts
        raise LoadError, 'Incompatible snapshot' unless part.digest == data[:digest]

        part.instance_variable_set(:@entities, data[:entities])
        part.instance_variable_set(:@players, data[:players])
        part.instance_variable_set(:@theater, data[:theater])
        part.players.each do |plyr|
          plyr.playbooks.add part.playbook
          plyr.scenebooks.add part.scenebook
        end
        part
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
