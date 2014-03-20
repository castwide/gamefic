require 'rubygems/package'
require 'zlib'
require 'tmpdir'
require 'getoptlong'

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

module Gamefic

  class Shell
    attr_accessor :argv
    def initialize
    
    end
    def execute
      if ARGV.length == 0
        ARGV.push 'help'
      end
      cmd = ARGV.shift
      case cmd
        when 'play'
          play ARGV.shift
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
          play cmd
      end
    end
    private
      def play file
        if !File.exist?(file)
          puts "'#{file}' does not exist."
          exit 1
        end
        if File.directory?(file)
          puts "'#{file}' is not a Gamefic file."
          exit 1
        end
        Dir.mktmpdir 'gamefic_' do |dir|
          story = Story.new
          begin
            decompress file, dir
          rescue Exception => e
            puts "'#{file}' does not appear to be a valid Gamefic file."
            puts "#{e}"
            exit 1
          end
          story.load dir + '/main.rb'
          engine = Engine.new story
          engine.run
        end
      end
      def test path
        story = Story.new
        begin
          if File.directory?(path)
            if !File.file?(path + '/main.rb')
              raise "#{path}/main.rb does not exist"
            end
            story.load path + '/main.rb'
          else
            story.load path
          end
        rescue Exception => e
          puts "An error occurred in #{path}:"
          puts "#{e}"
          exit 1
        end
        engine = Engine.new story
        engine.run
      end
      def init directory
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
import 'basics'

room = make Room, :name => 'room'

introduction do |player|
  player.parent = room
  player.perform "look"
end
EOS
        main_rb.close
        puts "Game directory '#{directory}' initialized."
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
        story = Story.new
        begin
          story.load directory + '/main.rb'
        rescue Exception => e
          puts "'#{directory}' has errors or is not a valid source directory."
          puts "#{e}"
          exit 1
        end
        puts "Checking for external script references..."
        story.declared_scripts.each { |script|
          if !script.start_with?(directory)
            base = script[(script.index('import/') + 7)..-1]
            puts "Fetching #{base}"
            FileUtils.mkdir_p directory + '/import/' + File.dirname(base)
            FileUtils.copy script, directory + '/import/' + base
          end
        }
        puts "Done"
      end
      def build directory
        if directory.to_s == ''
          puts "No source directory was specified."
          exit 1
        end
        if !File.directory?(directory)
          puts "#{directory} is not a directory."
          exit 1
        end
        filename = File.basename(directory) + '.gfic'
        opts = GetoptLong.new(
          [ '-o', '--output', GetoptLong::REQUIRED_ARGUMENT ]
        )
        opts.quiet = true
        begin
          opts.each { |opt, arg|
            case opt
              when '-o'
                filename = arg
            end
          }
        rescue Exception => e
          puts "#{e}"
          exit 1
        end
        if File.exist?(filename)
          puts "The file #{filename} already exists."
          exit 1
        end
        story = Story.new
        puts "Loading game data..."
        begin
          story.load directory + '/main.rb'
        rescue Exception => e
          puts "'#{directory}' has errors or is not a valid source directory."
          puts "#{e}"
          exit 1
        end
        puts "Building file..."
        stream = StringIO.new("")
        Gem::Package::TarWriter.new(stream) do |tar|
          Gem::Package::TarHeader.set_mtime Time.now
          tar.add_file('main.rb', 0600) do |io|
            File.open(directory + '/main.rb', "rb") { |f| io.write f.read }
          end
          if story.declared_scripts.length > 0
            Gem::Package::TarHeader.set_mtime Time.now
            tar.mkdir('import', 0700)
            story.declared_scripts.each { |script|
              base = script[script.index('import/') + 7..-1]
              Gem::Package::TarHeader.set_mtime Time.now
              tar.add_file('import/' + base, 0700) do |io|
                File.open(script, "rb") { |f| io.write f.read }
              end
            }
          end
        end
        gz = StringIO.new("")
        z = Zlib::GzipWriter.new(gz)
        z.mtime = Time.now
        z.write stream.string
        z.close
        file = File.new(filename, "w")
        file.write gz.string
        file.close
        puts "Gamefic file '#{filename}' complete."
      end
      def help command
        shell_script = File.basename($0)
        case command
          when "play"
            puts <<EOS
#{shell_script} play [file]
Play a Gamefic file on the command line.
EOS
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
If the specified game directory imnports external scripts, such as the ones
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
#{shell_script} play [file] - play a Gamefic file
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
