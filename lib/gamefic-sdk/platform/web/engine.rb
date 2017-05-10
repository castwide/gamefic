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
        #@user.update @character.state
        turn
      end

      def turn
        @plot.ready
        unless @character.state[:options].nil?
          list = '<ol class="multiple_choice">'
          @character.state[:options].each { |o|
            list += "<li><a href=\"#\" rel=\"gamefic\" data-command=\"#{o}\">#{o}</a></li>"
          }
          list += "</ol>"
          @character.tell list
        end
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
