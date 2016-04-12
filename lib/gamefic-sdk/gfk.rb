require 'tmpdir'
require 'zip'
require 'getoptlong'
require 'gamefic/engine/tty'
require 'gamefic-sdk'
require 'gamefic-sdk/build'
require 'securerandom'
require 'gamefic-sdk/debug'

include Gamefic

module Gamefic::Sdk
  class Gfk
    attr_accessor :argv
    def initialize
        
    end
    def execute
      if ARGV.length == 0
        ARGV.push 'help'
      end
      cmd = ARGV.shift
      case cmd
        when 'test'
          test ARGV.shift
        when 'init'
          init ARGV.shift
        when 'build'
          build ARGV.shift
        when 'clean'
          clean ARGV.shift
        when 'fetch'
          fetch ARGV.shift
        when 'help'
          help ARGV.shift
        else
          help nil
      end
    end
    private
      def test path
        puts "Loading..."
        STDOUT.flush
        if !File.exist?(path)
          raise "Invalid path: #{path}"
        end
        build_file = nil
        main_file = path
        test_file = nil
        if File.directory?(path)
          ext = nil
          ['plot.rb', 'plot', 'rb'].each { |e|
            if File.file?(path + '/main.' + e)
              ext = e
              break
            end
          }
          raise "#{path}/main.plot does not exist" if ext.nil?
          if File.file?(path + '/test.plot.rb')
            test_file = path + '/test.plot.rb'
          end
          main_file = path + '/main.' + ext
          config = YAML.load(File.read("#{path}/config.yaml"))
        else
          config = Build.load
        end
        if !File.file?(path + '/build.yaml')
        end
        plot = Gamefic::Sdk::Debug::Plot.new
        plot.source.directories.concat config['sources']['script_paths']
        plot.source.directories.push Gamefic::Sdk::GLOBAL_SCRIPT_PATH
        plot.load main_file
        if test_file != nil
          plot.load test_file
        end
        plot.script 'debug'
        engine = Tty::Engine.new plot
        puts "\n"
        engine.run
      end
      def init directory
        quiet = false
        html = nil
        imports = []
        opts = GetoptLong.new(
          [ '-q', '--quiet', GetoptLong::NO_ARGUMENT ],
          [ '--with-html', GetoptLong::REQUIRED_ARGUMENT ],
          [ '-i', '--import', GetoptLong::REQUIRED_ARGUMENT ]
        )
        begin
          opts.each { |opt, arg|
            case opt
              when '-q'
                quiet = true
              when '--with-html'
                html = arg
              when '-i'
                imports = arg.split(';')
            end
          }
        rescue Exception => e
          puts "#{e}"
          exit 1
        end
        if directory.to_s == ''
          puts "No directory specified."
          exit 1
        elsif File.exist?(directory)
          if File.directory?(directory)
            files = Dir[directory + '/*']
            if files.length > 0
              dotfiles = Dir[directory + '/\.*']
              if dotfiles.length < files.length
                puts "'#{directory}' is not an empty directory."
                exit 1
              end
            end
          else
            puts "'#{directory}' is a file."
            exit 1
          end
        else
          Dir.mkdir(directory)
        end
        Dir.mkdir(directory + '/scripts')
        main_rb = File.new(directory + '/main.plot.rb', 'w')
        main_rb.write <<EOS
require 'standard'
EOS
        imports.each { |i|
          main_rb.write "require '#{i}'\n"
        }
        main_rb.close
        test_rb = File.new(directory + '/test.plot.rb', 'w')
        test_rb.write <<EOS
require 'standard/test'
EOS
        test_rb.close
        build_rb = File.new(directory + '/build.yaml', 'w')
        build_rb.write <<EOS
web:
  platform: Web
gfic:
  platform: Gfic
EOS
        build_rb.close
        config_rb = File.new(directory + '/config.yaml', 'w')
        config_rb.write <<EOS
title: Untitled
author: Anonymous

sources:
  script_paths:
    - ./scripts
  asset_paths:
    - ./assets
EOS
        config_rb.close
        Dir.mkdir(directory + '/html')
        if !html.nil?
          FileUtils.cp_r(Dir[Gamefic::Sdk::HTML_TEMPLATE_PATH + "/core/*"], directory + "/html")
          FileUtils.cp_r(Dir[Gamefic::Sdk::HTML_TEMPLATE_PATH + "/skins/" + html + "/*"], directory + "/html")
        end
        uuid = SecureRandom.uuid
        File.open("#{directory}/.uuid", "w") { |f| f.write uuid }
        puts "Game directory '#{directory}' initialized." unless quiet
      end
      def fetch directory
        if directory.to_s == ''
          puts "No source directory was specified."
          exit 1
        end
        if !File.directory?(directory)
          puts "#{directory} is not a directory."
          exit 1
        end
        puts "Loading game data..."
        story = Plot.new(Source.new(GLOBAL_SCRIPT_PATH))
        begin
          story.load directory + '/main', true
        rescue Exception => e
          puts "'#{directory}' has errors or is not a valid source directory."
          puts "#{e}"
          exit 1
        end
        puts "Checking for external script references..."
        fetched = 0
        story.imported_scripts.each { |script|
          if !script.filename.start_with?(directory)
            base = script.filename[(script.filename.rindex('scripts/') + 7)..-1]
            puts "Fetching #{base}"
            FileUtils.mkdir_p directory + '/scripts/' + File.dirname(base)
            FileUtils.copy script.filename, directory + '/scripts/' + base
            fetched += 1
          end
        }
        if fetched == 0
          puts "Nothing to fetch."
        else
          puts "Done."
        end
      end
      def build directory
        Build.release directory
      end
      def clean directory
        #build_file = nil
        #if File.file?(directory + '/build.rb')
        #  build_file = directory + '/build.rb'
        #end
        #config = Build.load build_file
        config = YAML.load(File.read(directory + '/build.yaml'))
        Build.clean directory, config
      end
      def help command
        shell_script = File.basename($0)
        case command
          when "test"
            puts <<EOS
#{shell_script} test [path]
Test a Gamefic source directory or script.
EOS
          when "init"
            puts <<EOS
#{shell_script} init [directory]
Initialize a Gamefic source directory. The resulting directory will contain
source files ready to build into a Gamefic file.
EOS
          when "fetch"
            puts <<EOS
#{shell_script} fetch [directory]
Copy shared scripts to the source directory.
If the specified game directory imports external scripts, such as the ones
that are distributed with the Gamefic gem, this command will copy them into
the game's script directory. Fetching can be useful if you want to customize
common features.
EOS
          when "build"
            puts <<EOS
#{shell_script} build [directory] [-o | --output filename]
Build a distributable Gamefic file from the source directory. The default
filename is [directory].gfic. You can change the filename with the -o option.
EOS
          when "clean"
            puts <<EOS
#{shell_script} clean [directory]
Clean Gamefic source directories. This command will delete any intermediate
files that are used during the build process. The next build will rebuild
everything from source.
EOS
          when nil, "help"
          puts <<EOS
#{shell_script} init [directory] - initialize a Gamefic source directory
#{shell_script} test [path] - test a Gamefic source directory or script
#{shell_script} fetch [directory] - copy shared scripts into directory
#{shell_script} build [directory] - build games
#{shell_script} build [directory] - clean game directories
#{shell_script} help - display this message
#{shell_script} help [command] - display info about command
EOS
        else
          puts "Unrecognized command '#{command}'"
          exit 1
        end
      end
  end

end
