require 'securerandom'
require 'fileutils'
require 'getoptlong'

class Gamefic::Sdk::Shell::Command::Init < Gamefic::Shell::Command::Base
  def initialize
    @quiet = false
    @html = 'standard'
    @scripts = ['standard']
    @platforms = ['Gfic', 'Web']
    options.boolean '-q', '--quiet', 'suppress output', default: false
  end
  
  def run input
    get_arguments input
    make_game_directories
    write_main_script
    write_test_script
    write_build_yaml
    write_config_yaml
    write_uuid_file
    copy_html_skin
    Dir.mkdir("#{@directory}/media")
    puts "Game directory '#{@directory}' initialized." unless @quiet
  end
  
  private
  
  def get_arguments input
    result = parse input
    @quiet = result['--quiet']
    @directory = result.arguments[1]
  end

  def make_game_directories
    if @directory.to_s == ''
      raise "No directory specified."
    end
    if File.exist?(@directory)
      if File.file?(@directory)
        raise "#{@directory} is a file."
      else
        if !Dir['your_directory/*'].empty?
          raise "#{@directory} is not an empty directory."
        end
      end
    else
      Dir.mkdir(@directory)
    end
    Dir.mkdir(@directory + '/scripts')
  end
  
  def write_main_script
    File.open("#{@directory}/scripts/main.plot.rb", 'w') do |file|
      @scripts.each { |script|
        file.puts "script '#{script}'"
      }
    end
  end
  
  def write_test_script
    File.open("#{@directory}/scripts/test.plot.rb", 'w') do |file|
      file.puts "script 'standard/test'"
    end
  end
  
  def write_build_yaml
    File.open("#{@directory}/build.yaml", 'w') do |file|
      file.puts "web:",
      "  platform: Web",
      "gfic:",
      "  platform: Gfic"
    end
  end
  
  def write_config_yaml
    File.open("#{@directory}/config.yaml", 'w') do |file|
      file.puts "title: Untitled",
      "author: Anonymous",
      "",
      "script_paths:",
      "  - ./scripts",
      "media_paths:",
      "  - ./media"
    end
  end
  
  def write_uuid_file
    uuid = SecureRandom.uuid
    File.open("#{@directory}/.uuid", "w") { |f| f.write uuid }
  end
  
  def copy_html_skin
    Dir.mkdir("#{@directory}/html")
    skin = 'standard'
    FileUtils.cp_r(Dir[Gamefic::Sdk::HTML_TEMPLATE_PATH + "/skins/" + @html + "/*"], "#{@directory}/html")
  end
  
end
