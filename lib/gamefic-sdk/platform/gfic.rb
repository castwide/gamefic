require 'zip'
require 'tempfile'
require 'yaml'

module Gamefic::Sdk

  class Platform::Gfic < Platform::Base
    def build
      FileUtils.rm filename if File.file?(filename)
      FileUtils.mkdir_p release_path
      Zip::File.open(filename, Zip::File::CREATE) do |zipfile|
        plot.imported_scripts.each { |script|
          zipfile.add File.join('scripts', "#{script.path}.plot.rb"), script.absolute_path
        }
        Tempfile.open('metadata.yaml') do |file|
          file.puts metadata.to_yaml
          zipfile.add "metadata.yaml", file.path
        end
      end
    end

    def filename
      @filename ||= File.join(release_path, (config['platforms'][name]['filename'] || 'game.gfic'))
    end
  end
  
end
