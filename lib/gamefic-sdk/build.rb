require 'yaml'

module Gamefic::Sdk

  module Build
    def self.release directory, quiet = false
      config = Gamefic::Sdk::Config.load(directory)
      if config.auto_import?
        puts "Importing scripts..."
        Shell.start ['import', directory, '--quiet']
      end
      config.targets.each_pair { |k, v|
        plat = Gamefic::Sdk::Platform.load(config, k)
        puts "Clearing #{k}..."
        FileUtils.rm_rf plat.build_dir, secure: true
        puts "Building #{k}..." unless quiet
        plat.build
      }
      puts "Build#{config.targets.length > 1 ? 's' : ''} complete." unless quiet
    end
  end

end
