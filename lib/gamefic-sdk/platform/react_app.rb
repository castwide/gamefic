module Gamefic
  module Sdk
    module Platform
      # Compile the project into a React application.
      #
      class ReactApp < Webpack
        def make_target
          FileUtils.mkdir_p target_dir
          write_files_to_target File.join(Gamefic::Sdk::PLATFORMS_PATH, 'reactapp')
          Dir.chdir target_dir do
            system "npm", "install"
          end
        end

        def start
          Thread.new do
            STDERR.puts "ROot path: #{config.root_path}"
            Gamefic::Sdk::Server.set :source_dir, config.root_path
            Gamefic::Sdk::Server.set :browser, false
            Gamefic::Sdk::Server.set :public_folder, target_dir
            Gamefic::Sdk::Server.run!
          end
          Dir.chdir target_dir do
            STDERR.puts "Target dir: #{target_dir}"
            pid = Process.spawn "npm", "--prefix", target_dir, "run", "start"
            Process.wait pid
          end
        end
      end
    end
  end
end
