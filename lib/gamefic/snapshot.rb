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
      plot
    end

    class << self
      private

      def collect plot
        {
          plot: {
            klass: plot.class.to_s,
            entities: plot.entities,
            players: plot.players,
            theater: plot.instance_variable_get(:@theater)
          },
          subplots: collect_subplots(plot.subplots)
        }
      end

      def collect_subplots subplots
        subplots.map do |sp|
          {
            klass: sp.class.to_s,
            config: sp.config,
            entities: sp.entities,
            players: sp.players,
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

      def rebuild data
        klass = string_to_constant(data[:klass])
        part = klass.allocate
        part.instance_variable_set(:@config, data[:config])
        part.run_scripts
        part.instance_variable_set(:@entities, data[:entities])
        part.instance_variable_set(:@players, data[:players])
        part.instance_variable_set(:@theater, data[:theater])
        part.players.each do |plyr|
          plyr.playbooks.push part.playbook
          plyr.scenebooks.push part.scenebook
        end
        part
      end
    end
  end
end
