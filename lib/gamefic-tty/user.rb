require 'gamefic/engine'
require 'json'

module Gamefic
  module Tty
    # Extend Gamefic::User to convert HTML into ANSI text.
    #
    class User < Gamefic::User
      def update
        unless character.state[:options].nil?
          list = '<ol class="multiple_choice">'
          character.state[:options].each { |o|
            list += "<li><a href=\"#\" rel=\"gamefic\" data-command=\"#{o}\">#{o}</a></li>"
          }
          list += "</ol>"
          character.tell list
        end
        print Gamefic::Tty::Text::Html::Conversions.html_to_ansi(character.state[:output])
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
