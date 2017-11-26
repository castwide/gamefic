module Gamefic::Sdk
  module Platform
    class Webpack < Base
      include OpalBuilder

      def build
        FileUtils.mkdir_p build_dir
        File.write File.join(build_dir, 'opal.js'), build_opal_str
        FileUtils.mkdir_p File.join(build_dir, 'media')
        FileUtils.cp_r File.join(config.media_path, '.'), File.join(build_dir, 'media')
        abs_build = File.absolute_path(build_dir)
        Dir.chdir target_dir do
          system 'webpack', '-p'
        end
      end

      # The Webpack platform initializes a base package.json with dependencies
      # on webpack and gamefic-driver. Subclasses can install additional
      # dependencies as necessary.
      #
      def make_target
        FileUtils.mkdir_p target_dir
        Dir.chdir target_dir do
          system "npm", "init", "-y"
          system "npm", "install", "webpack", "--save-dev"
          system "npm", "install", "gamefic-driver", "--save"
        end
      end
    end
  end
end
