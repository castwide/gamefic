require 'zip'
  
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
        filename = target_dir + '/' + source_dir.split('/').delete_if{|i| i.to_s == ''}.last + '.gfic'
      else
        filename = "#{target_dir}/#{config['filename']}"
      end
      stream = StringIO.new("")
      FileUtils.rm filename if File.file?(filename)
      FileUtils.mkdir_p target_dir
      Zip::File.open(filename, Zip::File::CREATE) do |zipfile|
        if plot.imported_scripts.length > 0
          plot.imported_scripts.each { |script|
            zipfile.add "scripts/#{script.path}", script.absolute_path
          }
        end
      end
    end
  end
  
end
