require 'yaml'

module Gamefic::Sdk

  module Build
    def self.release directory, target: nil, quiet: false
      config = Gamefic::Sdk::Config.load(directory)
      raise "Invalid target #{target}" unless target.nil? or config.targets.key?(target)
      # if config.auto_import?
      #   puts "Importing scripts..."
      #   Shell.start ['import', '-d', directory, '--quiet']
      # end
      config.targets.each_pair { |k, v|
        next unless target.nil? or k == target
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
