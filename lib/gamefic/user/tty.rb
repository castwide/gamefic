require 'gamefic/engine'
require 'json'
require 'gamefic/text'

module Gamefic

  # Extend User::Base to convert HTML into ANSI text.
  #
  # @note Due to their dependency on io/console, User::Tty and Engine::Tty are
  #   not included in the core Gamefic library. `require gamefic/tty` if you
  #   need them.
  #
  class User::Tty < User::Base
    def save filename, snapshot
      json = JSON.generate snapshot
      if json.nil?
        @character.tell "Nothing to save."
      end
      if filename.nil?
        stream.select "Enter the filename to save:"
        filename = stream.queue.pop
      end
      if filename != ''
        File.open(filename, 'w') do |f|
          f.write json
        end
      end
    end

    def restore filename
      if filename.nil?
        stream.select "Enter the filename to restore:"
        filename = stream.queue.pop
      end
      if filename != ''
        if File.exists?(filename)
          data = JSON.parse File.read(filename), symbolize_names: true
          #if (data[:metadata] != @character.plot.metadata)
          #  @character.tell "The save file is not compatible with this version of the game."
          #else
            return data
          #end
        else
          @character.tell "File \"#{filename}\" not found."
        end
      end
      nil
    end

    def peek
      Gamefic::Text::Html::Conversions.html_to_ansi(super)
    end

    def flush
      Gamefic::Text::Html::Conversions.html_to_ansi(super)
    end
  end

end
