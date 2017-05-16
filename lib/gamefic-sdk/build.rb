require 'yaml'

module Gamefic::Sdk

  module Build
    def self.release directory, quiet = false
      config = YAML.load(File.read(File.join(directory, 'config.yaml')))
      uuid_file = File.join(directory, '.uuid')
      if File.file?(uuid_file)
        config['uuid'] = File.read(uuid_file).strip
      end
      #build_file = File.join(directory, 'build.yaml')
      #platforms = YAML.load(File.read(build_file))
      platforms = config['platforms']
      platforms.each_pair { |k, v|
        cls = Gamefic::Sdk::Platform.const_get(v['platform'])
        plat = cls.new(directory, k, config)
        puts "Building #{k}..." unless quiet
        plat.build
      }
      puts "Build#{platforms.length > 1 ? 's' : ''} complete." unless quiet
    end
    def self.clean directory
      #build_file = File.join(directory, 'build.yaml')
      #config = YAML.load(File.read(build_file))
      config = YAML.load(File.read(File.join(directory, 'config.yaml')))
      config['platforms'].each_pair { |k, v|
        v['name'] = k
        puts "Cleaning #{k}..."
        #build_dir = "#{directory}/build/#{k}"
        #platform_dir = File.join(directory, "release", k)
        cls = Gamefic::Sdk::Platform.const_get(v['platform'])
        plat = cls.new(directory, k, config)
        plat.clean
      }
    end
  end

end
