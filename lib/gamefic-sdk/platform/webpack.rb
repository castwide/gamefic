module Gamefic::Sdk
  module Platform
    class Webpack < Base
      # Compile the project into a Node application using Webpack.
      #
      def build
        # Webpack builds assume that an npm build script does all the work
        # (compile plot scripts, copy media, etc.)
        Dir.chdir target_dir do
          system 'npm', 'run', 'build'
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

      def servable?
        true
      end
    end
  end
end
