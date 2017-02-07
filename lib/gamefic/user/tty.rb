require 'gamefic/engine'
require 'json'
require 'gamefic/text'

module Gamefic

  # Extend User::Base to convert HTML into ANSI text.
  #
  class User::Tty < User::Base
    def save filename, snapshot
      data = snapshot.merge(:metadata => @character.plot.metadata)
      json = JSON.generate data
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
        @character.tell "Game saved."
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
          if (data[:metadata] != @character.plot.metadata)
            @character.tell "The save file is not compatible with this version of the game."
          else
            return data
          end
        else
          @character.tell "File \"#{filename}\" not found."
        end
      end
      nil
    end

    def flush
      Gamefic::Text::Html::Conversions.html_to_ansi(super)
    end
  end

end
