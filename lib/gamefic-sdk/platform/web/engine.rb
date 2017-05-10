# @hack Explicit requires for Opal
require 'gamefic/plot/playbook'
require 'gamefic/grammar'
require 'gamefic/query'
require 'gamefic/grammar/verb_set'
require 'gamefic/grammar/conjugator'

module Gamefic
  module Engine
    class Web < Gamefic::Engine::Base      
      def post_initialize
        self.user_class = Gamefic::User::Web
      end

      def run
        connect
        @plot.introduce @character
        @plot.ready
        @user.update @character.state
      end

      def turn
        @plot.ready
        @user.update @character.state
        update unless @character.queue.empty?
      end

      def receive input
        @character.queue.push input unless input.nil?
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
