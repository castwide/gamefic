module Gamefic::Sdk
  module Platform
    class Webpack < Base
      include OpalBuilder

      def build
        FileUtils.mkdir_p build_dir
        File.write File.join(build_dir, 'opal.js'), build_opal_str
        abs_build = File.absolute_path(build_dir)
        Dir.chdir target_dir do
          pid = Process.spawn('webpack', '-p', '--output-path', abs_build)
          Process.wait pid
        end
      end
    end
  end
end
