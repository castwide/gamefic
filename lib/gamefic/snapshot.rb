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
      plot = Gamefic::Plot.allocate # @todo Store this like subplot classes
      rebuild plot, data[:plot]
      plot.block_default_scenes
      data[:subplots].each do |subdata|
        klass = string_to_constant(subdata[:klass])
        subplot = klass.allocate
        rebuild subplot, subdata
        plot.subplots.push subplot
      end
      plot
    end

    class << self
      private

      def collect plot
        {
          plot: {
            entities: plot.entities,
            players: plot.players,
            theater: plot.instance_variable_get(:@theater)
          },
          subplots: plot.subplots.map do |sp|
            {
              klass: sp.class.to_s,
              entities: sp.entities,
              players: sp.players,
              theater: sp.instance_variable_get(:@theater)
            }
          end
        }
      end

      def string_to_constant string
        space = Object
        string.split('::').each do |part|
          space = space.const_get(part)
        end
        space
      end

      def rebuild part, data
        part.run_scripts
        part.setup.entities.discard
        part.setup.scenes.hydrate
        part.setup.actions.hydrate
        part.instance_variable_set(:@entities, data[:entities])
        part.instance_variable_set(:@players, data[:players])
        part.instance_variable_set(:@theater, data[:theater])
        part.players.each do |plyr|
          plyr.playbooks.push part.playbook
          plyr.scenebooks.push part.scenebook
        end
      end
    end
  end
end
