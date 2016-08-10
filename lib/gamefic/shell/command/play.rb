require 'zip'
require 'tmpdir'
require 'gamefic/engine/tty'
require 'gamefic/shell'
require 'yaml'

class Gamefic::Shell::Command::Play < Gamefic::Shell::Command::Base
  include Gamefic
  
  def run input
    result = parse input
    file = result.arguments[1]
    raise "File not specified." if file.nil?
    raise "'#{file}' does not exist." if !File.exist?(file)
    raise "'#{file}' is a directory." if File.directory?(file)
    play file
  end

  private
  
  def decompress(zipfile, destination)
    Zip::File.open(zipfile) do |z|
      z.each do |entry|
        FileUtils.mkdir_p File.join(destination, File.dirname(entry.name))
        full_path = File.join(destination, entry.name)
        if !File.exist?(full_path)
          entry.extract full_path
        end
      end
    end
  end

  def play file
    Dir.mktmpdir 'gamefic_' do |dir|
      puts "Loading..."
      story = Plot.new(Source::File.new(File.join(dir, 'scripts')))
      begin
        decompress file, dir
      rescue Exception => e
        puts "'#{file}' does not appear to be a valid Gamefic file."
        #puts "Error: #{e.message}"
        #exit 1
      end
      story.script 'main'
      story.metadata = YAML.load_file File.join(dir, 'metadata.yaml')
      engine = Tty::Engine.new story
      puts "\n"
      engine.run
    end    
  end
end
