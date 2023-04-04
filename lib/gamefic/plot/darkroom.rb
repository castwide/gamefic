# frozen_string_literal: true

require 'base64'

module Gamefic
  class Plot
    class Darkroom
      # @param plot [Plot]
      def initialize plot
        @plot = plot
      end

      def save
        binary = Marshal.dump(archive_hash)
        Base64.encode64(binary)
      end

      def restore snapshot
        binary = Base64.decode64(snapshot)
        data = Marshal.load(binary)
        rebuild @plot, data[:plot]
        data[:subplots].each do |sp|
          subplot = sp[:klass].new(@plot)
          rebuild subplot, sp
          @plot.subplots.push subplot
        end
      end

      private

      def archive_hash
        {
          plot: {
            entities: @plot.entities,
            players: @plot.players,
            theater: @plot.instance_variable_get(:@theater)
          },
          subplots: @plot.subplots.map do |sp|
            {
              klass: sp.class,
              entities: sp.entities,
              players: sp.players,
              theater: sp.instance_variable_get(:@theater)
            }
          end
        }
      end

      def rebuild psp, data
        psp.instance_variable_set(:@entities, data[:entities])
        psp.instance_variable_set(:@players, data[:players])
        psp.instance_variable_set(:@theater, data[:theater])
        psp.players.each do |plyr|
          plyr.playbooks.push psp.playbook
          plyr.scenebooks.push psp.scenebook
        end
        psp.ready
      end
    end
  end
end
