require 'rubygems'
require 'rubygems/package'
require 'zlib'
require 'tmpdir'
require 'getoptlong'
require 'gamefic/engine/tty'

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
          puts "Loading..."
          story = Plot.new [dir + '/import']
          begin
            decompress file, dir
          rescue Exception => e
            puts "'#{file}' does not appear to be a valid Gamefic file."
            puts "#{e}"
            exit 1
          end
          story.load dir + '/main'
          engine = Tty::Engine.new story
          puts "\n"
          engine.run
        end
      end
      def help command
        shell_script = File.basename($0)
        case command
          when "play"
            puts <<EOS
#{shell_script} play [file]
Play a Gamefic file on the command line.
EOS
          when nil, "help"
          puts <<EOS
#{shell_script} play [file] - play a Gamefic file
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
