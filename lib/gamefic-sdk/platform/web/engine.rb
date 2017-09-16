# HACK: Explicit requires for Opal
require 'gamefic/plot/playbook'
require 'gamefic/plot/darkroom'
require 'gamefic/grammar'
require 'gamefic/query'
require 'gamefic/grammar/verb_set'
require 'gamefic/grammar/conjugator'

module Gamefic
  module Engine
    class Web < Gamefic::Engine::Base
      attr_reader :user

      def post_initialize
        self.user_class = Gamefic::User::Web
      end

      def run
        connect
        plot.introduce @user.character
        plot.ready
        @user.update
      end

      def turn
        @plot.ready
        @user.update
        update unless @user.character.queue.empty?
      end

      def receive input
        @user.character.queue.push input unless input.nil?
        update
      end

      private

      def update
        @plot.update
        turn
      end
    end
  end
end
