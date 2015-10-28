require 'yaml'

module Gamefic::Sdk

  module Build
    def self.release directory
      config = YAML.load(File.read("#{directory}/config.yaml"))
      if File.file?("#{directory}/.uuid")
        config['uuid'] = File.read("#{directory}/.uuid").strip
      end
      plot = Gamefic::Sdk::Debug::Plot.new
      plot.source.directories.concat config['sources']['import_paths']
      plot.source.directories.push Gamefic::Sdk::GLOBAL_IMPORT_PATH
      plot.load "#{directory}/main.plot"
      platforms = YAML.load(File.read("#{directory}/build.yaml"))
      platforms.each_pair { |k, v|
        v['name'] = k
        cls = Gamefic::Sdk::Platform.const_get(v['platform'])
        plat = cls.new(plot, v)
        puts "Building #{k}..." #unless quiet
        plat.build
      }
      puts "Build#{platforms.length > 1 ? 's' : ''} complete." #unless quiet
    end
    def self.clean directory, config
      if config.platforms.length > 0
        config.platforms.each_pair { |k, v|
          puts "Cleaning release/#{k}..."
          build_dir = "#{directory}/build/#{k}"
          platform_dir = "#{directory}/release/#{k}"
          v.clean build_dir, platform_dir
        }
      end
    end
  end

end
