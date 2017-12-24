# HACK: Explicit requires for Opal
require 'gamefic/world/playbook'
require 'gamefic/plot/darkroom'
require 'gamefic/grammar'
require 'gamefic/query'
require 'gamefic/grammar/verb_set'
require 'gamefic/grammar/conjugator'

module Gamefic
  module Opal
    class Engine < Gamefic::Engine
      attr_reader :user

      def post_initialize
        self.user_class = Gamefic::Opal::User
      end

      def run
        connect
        plot.introduce @user.character
        plot.ready
        @user.update
      end

      def turn
        @plot.ready
      end

      def receive input
        @user.character.queue.push input unless input.nil?
      end

      private

      def update
        @plot.update
        turn
      end
    end
  end
end
