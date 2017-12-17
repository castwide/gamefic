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
            system "npm", "install", "webpack", "webpack-dev-server", "babel-core", "babel-loader", "babel-preset-env", "babel-preset-react", "css-loader", "style-loader", "script-loader", "file-loader", "image-webpack-loader", "webpack-synchronizable-shell-plugin", "copy-webpack-plugin", "--save-dev"
            system "npm", "install", "react", "react-dom", "--save"
            system "npm", "install", "gamefic-driver", "react-gamefic", "--save"
          end
        end

        def start
          Thread.new do
            Gamefic::Sdk::Server.set :source_dir, config.root_path
            Gamefic::Sdk::Server.set :browser, false
            Gamefic::Sdk::Server.set :public_folder, target_dir
            Gamefic::Sdk::Server.run!
          end
          Dir.chdir target_dir do
            pid = Process.spawn "npm", "run", "start"
            Process.wait pid
          end
        end
      end
    end
  end
end
