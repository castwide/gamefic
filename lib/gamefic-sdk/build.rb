require 'yaml'

module Gamefic::Sdk

  module Build
    #def self.load filename = nil
    #  if !filename.nil?
    #    eval File.read(filename), nil, filename, 1
    #    directory = File.dirname(filename)
    #    Configuration.current.import_paths.each_index { |i|
    #      if Configuration.current.import_paths[i][0,1] != '/'
    #        Configuration.current.import_paths[i] = directory + '/' + Configuration.current.import_paths[i]
    #      end
    #    }
    #    Configuration.current.import_paths.unshift directory + '/import'
    #  else
    #    Configuration.new
    #  end
    #  Configuration.current.import_paths.push Gamefic::Sdk::GLOBAL_IMPORT_PATH
    #  Configuration.current
    #end
    def self.release directory
      config = YAML.load(File.read("#{directory}/config.yaml"))
      if File.file?("#{directory}/.uuid")
        config['metadata']['uuid'] = File.read("#{directory}/.uuid").strip
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
