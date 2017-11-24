require 'tempfile'
require 'yaml'
require 'zlib'
require 'base64'

module Gamefic::Sdk

  class Platform::Ruby < Platform::Base
    def build
      files = {}
      dir = File.dirname(File.dirname(`gem which gamefic`))
      # @type [Gem::Specification]
      gem = Gem::Specification.find_by_name('gamefic')
      files.merge! hash_files(gem.lib_files, dir)
      dir = File.dirname(File.dirname(`gem which gamefic-sdk`))
      gem = Gem::Specification.find_by_name('gamefic-sdk')
      files.merge! hash_files(gem.lib_files.select{|f| f.start_with?('lib/gamefic-tty')}, dir)
      plot.imported_scripts.each do |script|
        code = File.read(script.absolute_path)
        comp = Zlib::Deflate.deflate(code)
        files["scripts/#{script.path}.plot.rb"] = Base64.encode64(comp)
      end
      program = %(
#!/usr/bin/env ruby
require 'tmpdir'
require 'fileutils'
require 'zlib'
require 'base64'

files = #{files.inspect}

Dir.mktmpdir do |tmpdir|
  puts "Loading..."
  files.each_pair do |f, d|
    path = File.join(tmpdir, f)
    FileUtils.mkdir_p File.dirname(path)
    File.open(path, 'w+') do |file|
      file << Zlib::Inflate.inflate(Base64.decode64(d))
    end
  end
  $LOAD_PATH.unshift File.join(tmpdir, 'lib')
  require 'gamefic'
  require 'gamefic-tty'
  plot = Gamefic::Plot.new(Gamefic::Source::File.new(File.join(tmpdir, 'scripts')))
  plot.script 'main'
  engine = Gamefic::Tty::Engine.new(plot)
  engine.connect
  puts "\n"
  engine.run
end
).strip
      FileUtils.mkdir_p build_dir
      File.open(filename, 'w') do |file|
        file << program
      end
    end

    def filename
      @filename ||= File.join(build_dir, (target['filename'] || 'game'))
    end

    private

    def hash_files files, base = ''
      result = {}
      files.each do |file|
        code = File.read(File.join(base, file))
        comp = Zlib::Deflate.deflate(code)
        result[file] = Base64.encode64(comp)
      end
      result
    end
  end
end
