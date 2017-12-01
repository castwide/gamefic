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
          Dir.chdir target_dir do
            exec "npm", "run", "start"
          end
        end
      end
    end
  end
end
