module Gamefic::Sdk
  module Platform
    class Opal < Gamefic::Sdk::Platform::Base
      include Gamefic::Sdk::Platform::OpalBuilder

      def package_dir
        @package_dir ||= Pathname.new(config.source_dir).join(target['src']).to_s
      end

      def build
        FileUtils.mkdir_p release_target
        File.write File.join(release_target, 'opal.js'), build_opal_str
        #Dir.chdir package_dir do
        #  exec 'webpack', '-p', '--output-path', release_target
        #end
      end
    end
  end
end
