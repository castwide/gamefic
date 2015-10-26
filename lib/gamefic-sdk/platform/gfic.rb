require 'zip'
  
module Gamefic::Sdk

  class Gfic < Platform
    def defaults
      @defaults ||= {
        :filename => nil,
        :with_html => true,
        :with_media => true
      }
    end
    def build source_dir, target_dir, story
      return
      if config[:filename].to_s == ''
        filename = target_dir + '/' + source_dir.split('/').delete_if{|i| i.to_s == ''}.last + '.gfic'
      else
        filename = "#{target_dir}/#{config[:filename]}"
      end
      stream = StringIO.new("")
      FileUtils.rm filename if File.file?(filename)
      Zip::File.open(filename, Zip::File::CREATE) do |zipfile|
        main_file = nil
        ['plot','rb'].each { |e|
          if File.file?(source_dir + '/main.' + e)
            main_file = 'main.' + e
            break
          end
        }
        zipfile.add(File.basename(main_file), source_dir + "/" + main_file)
        if story.imported_scripts.length > 0
          story.imported_scripts.each { |script|
            zipfile.add "import#{script.relative}", script.absolute
          }
        end
      end
    end
  end
  
end
