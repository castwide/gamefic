module Gamefic::Sdk
  module Platform
    class Webpack < Base
      include OpalBuilder

      def build
        FileUtils.mkdir_p build_dir
        File.write File.join(build_dir, 'opal.js'), build_opal_str
        abs_build = File.absolute_path(build_dir)
        Dir.chdir target_dir do
          system 'webpack', '-p', '--output-path', abs_build
        end
      end

      def make_target
        FileUtils.mkdir_p target_dir
        Dir.chdir target_dir do
          system "npm", "init", "-y"
          system "npm", "install", "webpack", "--save-dev"
        end
      end
    end
  end
end
