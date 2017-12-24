require 'gamefic-sdk'
require 'pathname'
require 'erb'

module Gamefic::Sdk
  # The base Platform class for building applications from Gamefic projects.
  #
  class Platform::Base
    # @return [Gamefic::Sdk::Config]
    attr_reader :config

    # @return [Hash]
    attr_reader :target

    # @param config [Gamefic::Sdk::Config]
    # @param target [Hash]
    def initialize config: Gamefic::Sdk::Config.new, target: {}
      @config = config
      @target = target
    end

    # The name of the target. This typically corresponds to the target's
    # subdirectory in the project's targets directory, e.g.,
    # `/[project-name]/targets/[target-name]`.
    #
    # @return [String]
    def name
      @name ||= (target['name'] || self.class.to_s.split('::').last.downcase)
    end

    # The path to the build directory (the compiled game).
    #
    # @return [String]
    def build_dir
      @build_dir ||= File.join(config.build_path, name)
    end

    # The path to the target directory (the platform-specific code).
    #
    # @return [String]
    def target_dir
      @target_dir ||= File.join(config.target_path, name)
    end

    # Get an evaluated instance of the project's plot.
    #
    # @return [Gamefic::Plot]
    def plot
      if @plot.nil?
        paths = [config.script_path, config.import_path] + config.library_paths
        @plot = Gamefic::Plot.new(Gamefic::Plot::Source.new(*paths))
        @plot.script 'main'
      end
      @plot
    end

    # Build the target. Subclasses should override this method with the
    # process to compile the project into an application for the target's
    # platform.
    #
    def build
      # Platforms need to build/compile the deployment here.
      raise "The #{self.class} class does not have a build method"
    end

    # Make a build target for this platform. Subclasses can override this
    # method to initialize the target, copy files, etc.
    #
    def make_target
    end

    # Start the target project in development mode. Subclasses should override
    # this method.
    #
    def start
    end

    # Get a hash of build metadata.
    #
    # @return [Hash]
    def metadata
      hash = {}
      hash[:uuid] = config.uuid
      hash[:gamefic_version] = "#{Gamefic::VERSION}"
      hash[:sdk_version] = "#{Gamefic::Sdk::VERSION}"
      hash[:build_date] = "#{DateTime.now}"
      hash
    end

    protected

    # Write the specified directory of files to a target directory.
    # This method is typically used in the platform's make_target method.
    #
    # Most files will simply be copied, but ERB templates (e.g,
    # index.html.erb) will be rendered with a Binder that specifies the
    # project's configuration and the name of the target.
    #
    def write_files_to_target src_dir
      binder = Gamefic::Sdk::Binder.new(config, target['name'])
      Dir[File.join(src_dir, '**', '{.*,*}')].each do |file|
        if File.directory?(file)
          FileUtils.mkdir_p File.join(target_dir, file[src_dir.length+1..-1])
        else
          FileUtils.mkdir_p File.join(target_dir, File.dirname(file[src_dir.length+1..-1]))
          if File.extname(file) == '.erb'
            dst = File.join target_dir, file[src_dir.length+1..-5]
            File.write dst, ERB.new(File.read(file)).result(binder.get_binding)
          else
            FileUtils.cp file, File.join(target_dir, file[src_dir.length+1..-1])
          end
        end
      end
    end

    # Copy the project's media directory to the target's build directory.
    # This method is typically used in the platform's build method.
    #
    def copy_media
      return unless File.directory?(config.media_path)
      FileUtils.mkdir_p File.join(build_dir, '/media')
      Dir.entries(config.media_path).each do |entry|
        if entry != '.' and entry != '..'
          FileUtils.mkdir_p File.join(build_dir, 'media', File.dirname(entry))
          FileUtils.cp_r File.join(config.media_path, entry, '.'), File.join(build_dir, 'media', entry)
        end
      end
    end
  end
end
