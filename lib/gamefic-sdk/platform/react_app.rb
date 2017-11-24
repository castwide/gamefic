module Gamefic
  module Sdk
    module Platform
      class ReactApp < Webpack
        def make_target
          FileUtils.mkdir_p target_dir
          Dir.chdir target_dir do
            system "npm", "init", "-y"
            system "npm", "install", "webpack", "css-loader", "file-loader", "style-loader", "--save-dev"
            system "npm", "install", "react", "react-dom", "--save"
            system "npm", "install", "babel-core", "babel-loader", "babel-preset-es2015", "babel-preset-react", "--save"
            system "npm", "install", "gamefic-driver", "react-gamefic", "--save"
            FileUtils.cp_r File.join(Gamefic::Sdk::HTML_TEMPLATE_PATH, 'react', '.'), '.'
          end
        end
      end
    end
  end
end
