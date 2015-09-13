require 'zip'
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
          story = Plot.new(Source.new(dir + '/import'))
          begin
            decompress file, dir
          rescue Exception => e
            puts "'#{file}' does not appear to be a valid Gamefic file."
            puts e.backtrace
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
      def decompress(zipfile, destination)
        Zip::File.open(zipfile) do |z|
          z.each do |entry|
            FileUtils.mkdir_p "#{destination}/#{File.dirname(entry.name)}"
            entry.extract "#{destination}/#{entry.name}"
          end
        end
      end
  end

end
