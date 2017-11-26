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
        begin
          plot.introduce @user.character
          plot.ready
          @user.update
        rescue Exception => e
          STDERR.puts e.inspect
        end
      end

      def turn
        begin
          @plot.ready
          @user.update
        rescue Exception => e
          STDERR.puts e.inspect
        end
        update unless @user.character.queue.empty?
      end

      def receive input
        begin
          @user.character.queue.push input unless input.nil?
          update
        rescue Exception => e
          STDERR.puts e.inspect
        end
      end

      private

      def update
        begin
          @plot.update
          turn
        rescue Exception => e
          STDERR.puts e.inspect
        end
      end
    end
  end
end
