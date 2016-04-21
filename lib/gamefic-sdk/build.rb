require 'yaml'

module Gamefic::Sdk

  module Build
    def self.release directory, quiet = false
      config = YAML.load(File.read("#{directory}/config.yaml"))
      if File.file?("#{directory}/.uuid")
        config['uuid'] = File.read("#{directory}/.uuid").strip
      end
      platforms = YAML.load(File.read("#{directory}/build.yaml"))
      platforms.each_pair { |k, v|
        v['name'] = k
        cls = Gamefic::Sdk::Platform.const_get(v['platform'])
        plat = cls.new(directory, v)
        puts "Building #{k}..." unless quiet
        plat.build
      }
      puts "Build#{platforms.length > 1 ? 's' : ''} complete." unless quiet
    end
    def self.clean directory
      config = YAML.load(File.read("#{directory}/build.yaml"))
      config.each_pair { |k, v|
        v['name'] = k
        puts "Cleaning #{k}..."
        build_dir = "#{directory}/build/#{k}"
        platform_dir = "#{directory}/release/#{k}"
        cls = Gamefic::Sdk::Platform.const_get(v['platform'])
        plat = cls.new(directory, v)
        plat.clean
      }
    end
  end

end
