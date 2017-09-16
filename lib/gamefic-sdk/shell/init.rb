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
          copy_html_skin
          write_gemfile
          write_yardopts
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
          File.open("#{@directory}/config.yml", 'w') do |file|
            file << Gamefic::Sdk::Config.generate
          end
        end

        def write_uuid_file
          uuid = SecureRandom.uuid
          File.open("#{@directory}/.uuid", "w") { |f| f.write uuid }
        end

        def copy_html_skin
          Dir.mkdir("#{@directory}/html")
          if @webdir.nil?
            FileUtils.cp_r(Dir[Gamefic::Sdk::HTML_TEMPLATE_PATH + '/skins/' + @html + '/*'], "#{@directory}/html")
          else
            FileUtils.cp_r(Dir[File.join(File.realpath(@webdir), '*')], "#{@directory}/html")
          end
        end

        def write_gemfile
          File.open("#{@directory}/Gemfile", 'w') do |file|
            file << "source 'https://rubygems.org'"
            file << ""
            file << "gem 'gamefic'"
            file << ""
            file << "group :development do"
            file << "  gem 'gamefic-sdk'"
            file << "end"
          end
        end

        def write_yardopts
          File.open("#{@directory}/.yardopts", 'w') do |file|
            file << 'scripts/**/*.rb'
            file << 'imports/**/*.rb'
          end
        end
      end
    end
  end
end
