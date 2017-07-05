require 'thor'
require 'gamefic-tty'
require 'zip'
require 'tmpdir'
require 'yaml'

module Gamefic
  class Shell < Thor
    map %w[--version -v] => :version

    desc "--version, -v", "Print the version"
    def version
      puts "gamefic #{Gamefic::VERSION}"
    end
    
    desc 'play FILE_NAME', 'Execute a compiled (.gfic) game'
    option :verbose, type: :boolean, aliases: :v, desc: "Don't suppress Ruby exceptions"
    def play(file)
      Dir.mktmpdir 'gamefic_' do |dir|
        puts 'Loading...'
        decompress file, dir
        run_game(dir)
      end
    rescue Zip::Error => e
      puts "'#{file}' does not appear to be a valid Gamefic file."
      show_exception(e) if options[:verbose]
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      show_exception(e) if options[:verbose]
    end

    desc 'info FILE_NAME', 'Print information about a (.gfic) game'
    option :verbose, type: :boolean, aliases: :v, desc: "Don't suppress Ruby exceptions"
    def info(file)
      Dir.mktmpdir 'gamefic_' do |dir|
        decompress file, dir
        metadata = YAML.load_file File.join(dir, 'metadata.yaml')
        metadata.each { |k, v|
          puts "#{k}: #{v}"
        }
      end
    rescue StandardError, Zip::Error => e
      puts "'#{file}' does not appear to be a valid Gamefic file."
      show_exception(e) if options[:verbose]
    end
    
    # Custom error message for invalid command or filename
    def method_missing(symbol, *args)
      raise UndefinedCommandError, "Could not find command or file named \"#{symbol}\"."
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
      plot = Plot.new(Source::File.new(File.join(directory, 'scripts')))
      plot.script 'main'
      plot.metadata = YAML.load_file File.join(directory, 'metadata.yaml')
      #Engine::Tty.start(plot)
      Gamefic::Tty::Engine.start(plot)
    end
  end
end
