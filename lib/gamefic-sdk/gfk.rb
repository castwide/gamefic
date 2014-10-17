require 'rubygems'
require 'rubygems/package'
require 'zlib'
require 'tmpdir'
require 'getoptlong'
require 'gamefic/engine/tty'
require 'gamefic-sdk/build'
include Gamefic

# Crazy hack to set file mtimes in tar file
class Gem::Package::TarHeader
  @@mtime = Time.now
  def self.set_mtime(time)
    @@mtime = time
  end
  alias :initialize_orig :initialize
  def initialize(vals)
    initialize_orig(vals)
    @mtime = @@mtime
  end
end

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
        when 'fetch'
          fetch ARGV.shift
        when 'help'
          help ARGV.shift
        else
          help
      end
    end
    private
      def test path
        puts "Loading..."
        build_file = nil
        main_file = path
        test_file = nil
        if File.directory?(main_file)
          if !File.file?(path + '/main.rb')
            raise "#{path}/main.rb does not exist"
          end
          if File.file?(path + '/build.rb')
            build_file = path + '/build.rb'
          end
          if File.file?(path + '/test.rb')
            test_file = path + '/test.rb'
          end
          main_file = path + '/main.rb'
          config = Build.load build_file
          config.import_paths.unshift path + '/import'
          config.import_paths.each_index { |i|
            if config.import_paths[i][0,1] != '/'
              config.import_paths[i] = path + '/' + config.import_paths[i]
            end
          }
        else
          config = Build.load
        end
        config.import_paths.push Gamefic::GLOBAL_IMPORT_PATH
        plot = Plot.new config
        plot.load main_file
        if test_file != nil
          plot.load test_file
        end
        plot.import 'debug'
        engine = Tty::Engine.new plot
        puts "\n"
        engine.run
      end
      def init directory
        quiet = false
        opts = GetoptLong.new(
          [ '-q', '--quiet', GetoptLong::NO_ARGUMENT ]
        )
        begin
          opts.each { |opt, arg|
            case opt
              when '-q'
                quiet = true
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
          if !File.directory?(directory)
            files = Dir[directory + '/*']
            if files.length > 0
              puts "'#{directory}' is not an empty directory."
              exit 1
            end
          else
            puts "'#{directory}' is not an empty directory."
            exit 1
          end
        else
          Dir.mkdir(directory)
        end
        Dir.mkdir(directory + '/import')
        main_rb = File.new(directory + '/main.rb', 'w')
        main_rb.write <<EOS
import 'standard'
EOS
        main_rb.close
        test_rb = File.new(directory + '/test.rb', 'w')
        test_rb.write <<EOS
import 'standard/test'
EOS
        test_rb.close
        build_rb = File.new(directory + '/build.rb', 'w')
        build_rb.write <<EOS
Build::Configuration.new do |config|
  config.import_paths << './import'
  config.target Gfic.new
  config.target Web.new
end
EOS
        build_rb.close
        #fetch directory
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
        story = Plot.new
        begin
          story.load directory + '/main.rb', true
        rescue Exception => e
          puts "'#{directory}' has errors or is not a valid source directory."
          puts "#{e}"
          exit 1
        end
        puts "Checking for external script references..."
        fetched = 0
        story.imported_scripts.each { |script|
          if !script.filename.start_with?(directory)
            base = script.filename[(script.filename.rindex('import/') + 7)..-1]
            puts "Fetching #{base}"
            FileUtils.mkdir_p directory + '/import/' + File.dirname(base)
            FileUtils.copy script.filename, directory + '/import/' + base
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
        quiet = false
        force = false
        if directory.to_s == ''
          puts "No source directory was specified."
          exit 1
        end
        if !File.directory?(directory)
          puts "#{directory} is not a directory."
          exit 1
        end
        config = nil
        build_file = nil
        if File.file?(directory + '/build.rb')
          build_file = directory + '/build.rb'
        end
        config = Build.load build_file
        config.import_paths.each_index { |i|
          if config.import_paths[i][0,1] != '/'
            config.import_paths[i] = directory + '/' + config.import_paths[i]
          end
        }
        config.import_paths.unshift directory + '/import'
        config.import_paths.push Gamefic::GLOBAL_IMPORT_PATH
        filename = File.basename(directory) + '.gfic'
        opts = GetoptLong.new(
          [ '-o', '--output', GetoptLong::REQUIRED_ARGUMENT ],
          [ '-q', '--quiet', GetoptLong::NO_ARGUMENT ],
          [ '-f', '--force', GetoptLong::NO_ARGUMENT ]
        )
        begin
          opts.each { |opt, arg|
            case opt
              when '-o'
                filename = arg
              when '-q'
                quiet = true
              when '-f'
                force = true
            end
          }
        rescue Exception => e
          puts "#{e}"
          exit 1
        end
        if File.exist?(filename) and !force
          puts "The file #{filename} already exists."
          exit 1
        end
        story = Plot.new config
        puts "Loading game data..." unless quiet
        begin
          story.load directory + '/main.rb'
        rescue Exception => e
          puts "'#{directory}' has errors or is not a valid source directory."
          puts "#{e}"
          exit 1
        end
        if config.platforms.length > 0
          config.platforms.each_pair { |k, v|
            puts "Building release/#{k}..." unless quiet
            platform_dir = "#{directory}/release/#{k}"
            v.build directory, platform_dir, story
          }
          puts "Build#{config.platforms.length > 1 ? 's' : ''} complete." unless quiet
        else
          puts "Build configuration does not have any target platforms."
        end
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
the game's import directory. Fetching can be useful if you want to customize
common features.
EOS
          when "build"
            puts <<EOS
#{shell_script} build [directory] [-o | --output filename]
Build a distributable Gamefic file from the source directory. The default
filename is [directory].gfic. You can change the filename with the -o option.
EOS
          when nil, "help"
          puts <<EOS
#{shell_script} init [dir] - initialize a Gamefic source directory
#{shell_script} test [path] - test a Gamefic source directory or script
#{shell_script} fetch [directory] - copy shared scripts into directory
#{shell_script} build [directory] - build a Gamefic file
#{shell_script} help - display this message
#{shell_script} help [command] - display info about command
EOS
        else
          puts "Unrecognized command '#{command}'"
          exit 1
        end
      end
      def decompress(tarfile, destination)
        tar_longlink = '././@LongLink'
        Gem::Package::TarReader.new( Zlib::GzipReader.open tarfile ) do |tar|
          dest = nil
          tar.each do |entry|
            if entry.full_name == tar_longlink
              dest = File.join destination, entry.read.strip
              next
            end
            dest ||= File.join destination, entry.full_name
            if entry.directory?
              FileUtils.rm_rf dest unless File.directory? dest
              FileUtils.mkdir_p dest, :mode => entry.header.mode, :verbose => false
            elsif entry.file?
              cur_stack = dest.split('/')
              cur_stack.pop
              cur_dir = ''
              while cur_stack.length > 0
                cur_dir += '/' + cur_stack.shift              
                if !File.exist?(destination + cur_dir)
                  FileUtils.mkdir_p dest, :mode => 0700, :verbose => false
                end
              end
              FileUtils.mkdir_p dest, :mode => entry.header.mode, :verbose => false
              FileUtils.rm_rf dest unless File.file? dest
              File.open dest, "wb" do |f|
                f.print entry.read
              end
              FileUtils.chmod entry.header.mode, dest, :verbose => false
            elsif entry.header.typeflag == '2' #Symlink!
              File.symlink entry.header.linkname, dest
            end
            dest = nil
          end
        end
      end
  end

end
