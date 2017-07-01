require 'gamefic/engine'
require 'json'
require 'gamefic/text'

module Gamefic
  module Tty
    # Extend User::Base to convert HTML into ANSI text.
    #
    # @note Due to their dependency on io/console, User::Tty and Engine::Tty are
    #   not included in the core Gamefic library. `require gamefic/tty` if you
    #   need them.
    #
    class User < Gamefic::User::Base
      def update
        unless character.state[:options].nil?
          list = '<ol class="multiple_choice">'
          character.state[:options].each { |o|
            list += "<li><a href=\"#\" rel=\"gamefic\" data-command=\"#{o}\">#{o}</a></li>"
          }
          list += "</ol>"
          character.tell list
        end
        print Gamefic::Text::Html::Conversions.html_to_ansi(character.state[:output])
      end

      def save filename, snapshot
        File.open(filename, 'w') do |file|
          file << snapshot.to_json
        end
      end

      def restore filename
        json = File.read(filename)
        snapshot = JSON.parse(json, symbolize_names: true)
        engine.plot.restore snapshot
      end
    end
  end
end
