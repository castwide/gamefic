module Gamefic::Sdk

  class Gfic < Platform
    def defaults
      @defaults ||= {
        :filename => File.dirname(__FILE__).split('/').last + '.gfic',
        :with_html => true,
        :with_media => true
      }
    end
    def build source_dir, target_dir, story
      raise "Gfic build needs a filename" if config[:filename].to_s == ''
      filename = "#{target_dir}/#{config[:filename]}"
      stream = StringIO.new("")
      Gem::Package::TarWriter.new(stream) do |tar|
        Gem::Package::TarHeader.set_mtime Time.now
        tar.add_file('main.rb', 0600) do |io|
          File.open(source_dir + '/main.rb', "rb") { |f| io.write f.read }
        end
        if story.imported_scripts.length > 0
          Gem::Package::TarHeader.set_mtime Time.now
          tar.mkdir('import', 0700)
          story.imported_scripts.each { |script|
            Gem::Package::TarHeader.set_mtime Time.now
            tar.add_file('import/' + script.relative, 0700) do |io|
              io.write File.read(script.absolute)
            end
          }
        end
        # TODO: We need to add the media directory and possibly others.
        # At least hardcode media.
        #config.extras.each { |extra|
        #  Dir[directory + '/' + extra].each { |file|
        #    if File.file?(file)
        #      Gem::Package::TarHeader.set_mtime Time.now
        #      tar.add_file(file[directory.length+1..-1].gsub(/\.\.\//, ''), 0700) do |io|
        #        io.write File.read(file)
        #      end
        #    end
        #  }
        #}
      end
      gz = StringIO.new("")
      z = Zlib::GzipWriter.new(gz)
      z.mtime = Time.now
      z.write stream.string
      z.close
      FileUtils.mkdir_p File.dirname(filename)
      file = File.new(filename, "w")
      file.write gz.string
      file.close
    end
  end

end
