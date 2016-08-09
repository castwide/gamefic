require 'zip'
require 'tmpdir'
require 'gamefic/engine/tty'
require 'gamefic/shell'
require 'yaml'

class Gamefic::Shell::Command::Play < Gamefic::Shell::Command::Base
  include Gamefic
  
  def run input
    result = parse input
    file = ARGV[1]
    raise "File not specified." if file.nil?
    raise "'#{file}' does not exist." if !File.exist?(file)
    raise "'#{file}' is a directory." if File.directory?(file)
    play file
  end

  private
  
  def decompress(zipfile, destination)
    Zip::File.open(zipfile) do |z|
      z.each do |entry|
        FileUtils.mkdir_p "#{destination}/#{File.dirname(entry.name)}"
        if !File.exist?("#{destination}/#{entry.name}")
          entry.extract "#{destination}/#{entry.name}"
        end
      end
    end
  end

  def play file
    Dir.mktmpdir 'gamefic_' do |dir|
      puts "Loading..."
      story = Plot.new(Source::File.new(dir + '/scripts'))
      begin
        decompress file, dir
      rescue Exception => e
        puts "'#{file}' does not appear to be a valid Gamefic file."
        #puts "Error: #{e.message}"
        #exit 1
      end
      story.script 'main'
      story.metadata = YAML.load_file "#{dir}/metadata.yaml"
      engine = Tty::Engine.new story
      puts "\n"
      engine.run
    end    
  end
end
