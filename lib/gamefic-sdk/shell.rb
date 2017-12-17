require 'thor'
require 'zip'
require 'tmpdir'
require 'yaml'
require 'gamefic-sdk/build'
require 'gamefic-tty'

module Gamefic
  module Sdk
    class Shell < Thor
      autoload :Init, 'gamefic-sdk/shell/init'
      autoload :Test, 'gamefic-sdk/shell/test'
      autoload :Ide, 'gamefic-sdk/shell/ide'
      autoload :Script, 'gamefic-sdk/shell/script'
      autoload :Plotter, 'gamefic-sdk/shell/plotter'

      include Plotter

      map %w[--version -v] => :version
      map [:create, :new] => :init
      map ['scripts'] => :script

      desc "--version, -v", "Print the version"
      def version
        puts "gamefic-sdk #{Gamefic::Sdk::VERSION}"
        puts "gamefic #{Gamefic::VERSION}"
      end

      desc 'init DIRECTORY_NAME', 'Create a new game in DIRECTORY_NAME'
      option :quiet, type: :boolean, aliases: :q, desc: 'Suppress output'
      option :standard, type: :boolean, default: true, desc: 'Include the standard script'
      option :scripts, type: :array, aliases: [:s, :script], desc: 'Additional scripts'
      option :title, type: :string, aliases: [:t], desc: "The game's title"
      option :author, type: :string, aliases: [:a], desc: "The game's author"
      def init(directory_name)
        Gamefic::Sdk::Shell::Init.new(
          directory: directory_name, quiet: options[:quiet], scripts: options[:scripts],
          title: options[:title], author: options[:author]
        ).run
      end

      desc 'test [DIRECTORY_NAME]', 'Run the project in DIRECTORY_NAME'
      def test(directory_name = '.')
        Gamefic::Sdk::Shell::Test.new(directory: directory_name).run
      end

      desc 'start [TARGET_NAME]', 'Start the specified target'
      def start target
        config = Gamefic::Sdk::Config.load('.')
        if config.auto_import?
          puts "Importing scripts..."
          Shell.start ['import', '.', '--quiet']
        end
        platform = Gamefic::Sdk::Platform.load(config, target)
        platform.start
      end

=begin
      desc 'server [DIRECTORY_NAME]', 'Run the game in DIRECTORY_NAME in a web server'
      option :target, type: :string, required: true, aliases: :t, desc: 'The target app'
      option :browser, type: :boolean, aliases: :b, desc: 'Open a browser when the server starts'
      def server(directory_name = '.')
        # @todo Should we make sure the target is built?
        config = Gamefic::Sdk::Config.load(directory_name)
        Gamefic::Sdk::Server.set :source_dir, directory_name
        Gamefic::Sdk::Server.set :browser, options[:browser]
        Gamefic::Sdk::Server.set :public_folder, File.join(config.build_path, options[:target])
        Gamefic::Sdk::Server.run!
      end
=end

      desc 'build [DIRECTORY_NAME]', 'Build the game for specified platforms in DIRECTORY_NAME'
      option :quiet, type: :boolean, aliases: :q, desc: 'Suppress output'
      def build(directory_name = '.')
        Gamefic::Sdk::Build.release(directory_name, options[:quiet])
      end

      desc 'import [DIRECTORY_NAME]', 'Copy external scripts to the project'
      option :quiet, type: :boolean, aliases: :q, desc: 'Suppress output'
      def import(directory_name = '.')
        config = Gamefic::Sdk::Config.load directory_name
        FileUtils.remove_entry_secure config.import_path if File.exist?(config.import_path)
        FileUtils.mkdir_p config.import_path
        paths = [config.script_path] + config.library_paths
        plot = Gamefic::Plot.new Source::File.new(*paths)
        plot.script 'main'
        plot.imported_scripts.each { |s|
          next if s.absolute_path.start_with?(config.script_path)
          src = File.absolute_path(s.absolute_path)
          dst = File.absolute_path(File.join(directory_name, 'imports', "#{s.path}.plot.rb"))
          next if src == dst
          puts "Importing #{s.path}" unless options[:quiet]
          FileUtils.mkdir_p(File.dirname(dst))
          FileUtils.cp_r(src, dst)
        }
      end

      desc 'default-config [DIRECTORY_NAME]', 'Create or overwrite config.yml with default values'
      def default_config(directory_name = '.')
        File.open(File.join(directory_name, 'config.yml'), 'w') do |file|
          file << Gamefic::Sdk::Config.generate
        end
        puts "Default config.yml created."
      end

      desc 'script [PATH]', 'List or document the scripts in the SDK'
      def script path = nil
        Gamefic::Sdk::Shell::Script.new(path).run
      end

      desc 'play FILE_NAME', 'Run a gamefic (.gfic) file'
      option :verbose, type: :boolean, aliases: :v, desc: "Don't suppress Ruby exceptions"
      def play(file)
        Dir.mktmpdir 'gamefic_' do |dir|
          puts 'Loading...'
          decompress file, dir
          run_game(dir)
        end
      rescue Zip::Error => e
        puts "'#{file}' does not appear to be a valid Gamefic file."
        show_exception(e) if options[:verbose]
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
        show_exception(e) if options[:verbose]
      end

      desc 'target PLATFORM_NAME [DIRECTORY_NAME]', 'Add a target to a project.'
      long_desc %(
        Add a target to a project.
        Run `gamefic platforms` for a list of available platform names.
      )
      def target platform_name, directory = nil
        directory ||= platform_name.downcase
        config = Gamefic::Sdk::Config.load('.')
        # @type [Class<Gamefic::Sdk::Platform::Base>]
        begin
          cls = Gamefic::Sdk::Platform.const_get(platform_name)
          raise NameError unless is_a_platform?(cls)
        rescue NameError
          puts "ERROR: '#{platform_name}' is not a valid platform name."
          puts "Run `gamefic platforms` for a list of available platforms."
          exit 1
        end
        target = config.targets[directory] || {
          'platform' => platform_name
        }
        platform = cls.new(config: config, target: target.merge('name' => directory))
        platform.make_target
        new_data = config.data.dup
        new_data['targets'] ||= {}
        new_data['targets'][directory] = target
        new_config = Gamefic::Sdk::Config.new('.', new_data)
        new_config.save
      end

      desc 'platforms', 'List available platforms.'
      def platforms
        Gamefic::Sdk::Platform.constants(false).each do |c|
          next if c == :Base or c == :Sinatra
          obj = Gamefic::Sdk::Platform.const_get(c)
          next unless obj.kind_of?(Class)
          puts c.to_s if platform?(obj)
        end
      end

      desc 'compile-opal', 'Generate an Opal file'
      option :output, type: :string, aliases: [:o], desc: "The output file"
      option :watch, type: :boolean, aliases: [:w], desc: "Watch for changes", default: false
      option :minify, type: :boolean, aliases: [:m], desc: "Minify the output", default: false
      option :sourcemap, type: :boolean, aliases: [:s], desc: "Include sourcemap", default: false
      def compile_opal
        config = Gamefic::Sdk::Config.load('.')
        if options[:minify] and options[:sourcemap]
          STDERR.puts "WARNING: Enabling --sourcemap disables --minify in compile-opal options"
          options[:minify] = false
        end
        begin
          write_opal_files config, options[:output], options[:minify], options[:sourcemap]
        rescue Exception => e
          STDERR.puts e.inspect
        end
        if options[:watch]
          compile_time = Time.now
          while true
            latest = Dir[config.script_path + '/**/*', config.import_path + '/**/*', config.media_path + '/**/*'].map{|f| File.mtime(f)}.max
            if latest > compile_time
              begin
                puts "Rebuilding #{File.basename(options[:output])}"
                write_opal_files config, options[:output], options[:minify], options[:sourcemap]
              rescue Exception => e
                STDERR.puts e.inspect
              end
              compile_time = latest
            end
            sleep 0.1
          end
        end
      end

      private

      def opal_builder_platform(config)
        platform = Gamefic::Sdk::Platform::Base.new(config: config)
        platform.extend Gamefic::Sdk::Platform::OpalBuilder
        platform
      end

      def write_opal_files config, output, minify, sourcemap
        platform = opal_builder_platform(config)
        code = platform.build_opal_str(minify)
        if sourcemap
          code += "\n//# sourceMappingURL=#{File.basename(output)}.map"
        end
        File.write output, code
        if sourcemap
          File.write "#{output}.map", platform.opal_builder.source_map.to_s
        end
      end

      def platform?(cls)
        until cls.nil?
          return true if cls == Gamefic::Sdk::Platform::Base
          cls = cls.superclass
        end
        false
      end

      def show_exception(exception)
        puts exception.inspect
        puts exception.backtrace.join("\n")
      end
  
      def decompress(zipfile, destination)
        Zip::File.open(zipfile) do |z|
          z.each do |entry|
            FileUtils.mkdir_p File.join(destination, File.dirname(entry.name))
            full_path = File.join(destination, entry.name)
            entry.extract full_path unless File.exist?(full_path)
          end
        end
      end
  
      def run_game(directory)
        plot = Plot.new(Source::File.new(File.join(directory, 'scripts')))
        plot.script 'main'
        plot.metadata = YAML.load_file File.join(directory, 'metadata.yaml')
        Gamefic::Tty::Engine.start(plot)
      end

      def is_a_platform?(klass)
        cursor = klass.superclass
        until cursor.nil?
          return true if cursor == Gamefic::Sdk::Platform::Base
          cursor = cursor.superclass
        end
        false
      end
    end
  end
end
