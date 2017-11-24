require 'securerandom'
require 'fileutils'

module Gamefic
  module Sdk
    class Shell
      class Init
        def initialize(directory:, standard: true, quiet: false, scripts: [], webskin: 'standard', webdir: nil, title: nil, author: nil)
          @quiet = quiet
          @directory = directory
          @html = webskin
          @webdir = webdir
          @scripts = []
          @scripts.push('standard') if standard
          @scripts += scripts if scripts
          @platforms = ['Gfic', 'Web']
          @title = title
          @author = author
        end

        def run
          make_game_directories
          write_main_script
          write_test_script
          write_config_yaml
          write_uuid_file
          write_gemfile
          write_yardopts
          write_solargraph_yml
          make_targets
          puts "Game directory '#{@directory}' initialized." unless @quiet
        end

        private

        def make_game_directories
          if File.exist?(@directory)
            raise "#{@directory} is a file." if File.file?(@directory)
            raise "#{@directory} is not an empty directory." unless Dir["#{@directory}/*"].empty?
          else
            Dir.mkdir(@directory)
          end

          Dir.mkdir(File.join(@directory, 'scripts'))
          Dir.mkdir(File.join(@directory, 'imports'))
          Dir.mkdir(File.join(@directory, 'media'))
        end

        def write_main_script
          main_file = File.join(@directory, 'scripts', 'main.plot.rb')
          File.open(main_file, 'w') do |file|
            @scripts.each do |script|
              file.puts "script '#{script}'"
            end
          end
        end

        def write_test_script
          File.open("#{@directory}/scripts/test.plot.rb", 'w') do |file|
            file.puts "script 'standard/test'"
          end
        end

        def write_config_yaml
          File.write File.join(@directory, 'config.yml'), Gamefic::Sdk::Config.generate
        end

        def write_uuid_file
          File.write File.join(@directory, '.uuid'), SecureRandom.uuid
        end

        def make_targets
          config = Gamefic::Sdk::Config.load(@directory)
          config.targets.each do |name, conf|
            plat = Gamefic::Sdk::Platform.load(config, name)
            plat.make_target
          end
        end

        def write_gemfile
          File.open("#{@directory}/Gemfile", 'w') do |file|
            file.puts "source 'https://rubygems.org'"
            file.puts ""
            file.puts "gem 'gamefic'"
            file.puts ""
            file.puts "group :development do"
            file.puts "  gem 'gamefic-sdk'"
            file.puts "end"
          end
        end

        def write_yardopts
          File.open("#{@directory}/.yardopts", 'w') do |file|
            file.puts 'scripts/**/*.rb'
            file.puts 'imports/**/*.rb'
          end
        end

        def write_solargraph_yml
          File.open("#{@directory}/.solargraph.yml", 'w') do |file|
            file.puts 'include:'
            file.puts '  - scripts/**/*.rb'
            file.puts '  - imports/**/*.rb'
            file.puts 'domains:'
            file.puts '  - Gamefic::Plot'
          end
        end
      end
    end
  end
end
