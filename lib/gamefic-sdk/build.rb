require 'yaml'

module Gamefic::Sdk

  module Build
    def self.release directory, quiet = false
      config = Gamefic::Sdk::Config.load(directory)
      config.targets.each_pair { |k, v|
        puts "Building #{k}..." unless quiet
        plat = Gamefic::Sdk::Platform.load(config, k)
        plat.build
      }
      puts "Build#{config.targets.length > 1 ? 's' : ''} complete." unless quiet
    end
    def self.clean directory
      config = Gamefic::Sdk::Config.load(directory)
      config.targets.each_pair { |k, v|
        puts "Cleaning #{k}..."
        plat = Gamefic::Sdk::Platform.load(config, k)
        plat.clean
      }
      puts "Done."
    end
  end

end
