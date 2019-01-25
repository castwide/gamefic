require 'securerandom'
require 'fileutils'

module Gamefic
  module Sdk
    class Shell
      class Init
        def initialize(directory:, standard: true, quiet: false, scripts: [], title: nil, author: nil)
          @quiet = quiet
          @directory = directory
          # @scripts = []
          # @scripts.push('standard') if standard
          # @scripts += scripts if scripts
          @title = title
          @author = author
        end

        def run
          make_game_directories
          write_main_script
          # @todo Temporarily disabled
          # write_test_script
          write_config_yaml
          write_uuid_file
          write_gemfile
          write_gitignore
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

          Dir.mkdir(File.join(@directory, 'lib'))
          # Dir.mkdir(File.join(@directory, 'imports'))
          Dir.mkdir(File.join(@directory, 'media'))
          Dir.mkdir(File.join(@directory, 'builds'))
        end

        def write_main_script
          main_file = File.join(@directory, 'lib', 'main.rb')
          File.open(main_file, 'w') do |file|
            file.puts "require 'gamefic-standard'"
            file.puts "\n"
            file.puts "Gamefic.script do"
            file.puts "  introduction do |actor|"
            file.puts "    actor.tell 'Hello, world!'"
            file.puts "  end"
            file.puts "end"
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
            file.puts "gem 'gamefic-standard'"
            file.puts ""
            file.puts "group :development do"
            file.puts "  gem 'gamefic-sdk'"
            file.puts "end"
          end
        end

        def write_gitignore
          File.open("#{@directory}/.gitignore", 'w') do |file|
            file.puts "./builds"
            file.puts "node_modules"
          end
        end
      end
    end
  end
end
