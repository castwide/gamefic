require 'zip'
require 'tempfile'
require 'yaml'

module Gamefic::Sdk

  class Platform::Gfic < Platform::Base
    def defaults
      @defaults ||= {
        :filename => nil,
        :with_html => true,
        :with_media => true
      }
    end
    def build
      target_dir = config['target_dir']
      if config['filename'].to_s == ''
        filename = File.join(target_dir, source_dir.split('/').delete_if{|i| i.to_s == ''}.last + '.gfic')
      else
        filename = File.join(target_dir, config['filename'])
      end
      FileUtils.rm filename if File.file?(filename)
      FileUtils.mkdir_p target_dir
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
  end
  
end
