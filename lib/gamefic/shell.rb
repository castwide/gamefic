require 'thor'
require 'gamefic/engine/tty'
require 'zip'
require 'tmpdir'
require 'yaml'

module Gamefic
  class Shell < Thor
    desc 'play FILE_NAME', 'Execute a compiled (.gfic) game'
    option :verbose, type: :boolean, aliases: :v, desc: "Don't suppress Ruby exceptions"

    def play(file)
      Dir.mktmpdir 'gamefic_' do |dir|
        puts 'Loading...'
        decompress file, dir
        run_game(dir)
      end
    rescue StandardError => e
      puts "'#{file}' does not appear to be a valid Gamefic file."
      show_exception(e) if options[:verbose]
    end

    private

    def show_exception(exception)
      puts exception.inspect
      puts exception.backtrace.join("\n")
    end

    def decompress(zipfile, destination)
      Zip::File.open(zipfile) do |z|
        z.each do |entry|
          FileUtils.mkdir_p File.join(destination, File.dirname(entry.name))
          full_path = File.join(destination, entry.name)
          entry.extract full_path unless File.exist?(full_path)
        end
      end
    end

    def run_game(directory)
      story = Plot.new(Source::File.new(File.join(directory, 'scripts')))
      story.script 'main'
      story.metadata = YAML.load_file File.join(directory, 'metadata.yaml')
      engine = Tty::Engine.new story
      puts "\n"
      engine.run
    end
  end
end
