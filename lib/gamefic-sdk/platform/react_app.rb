module Gamefic
  module Sdk
    module Platform
      class ReactApp < Webpack
        def make_target
          FileUtils.mkdir_p target_dir
          write_files_to_target File.join(Gamefic::Sdk::PLATFORMS_PATH, 'reactapp')
          Dir.chdir target_dir do
            system "npm", "install", "webpack", "webpack-dev-server", "babel-core", "babel-loader", "babel-preset-env", "babel-preset-react", "css-loader", "style-loader", "webpack-shell-plugin", "copy-webpack-plugin", "--save-dev"
            system "npm", "install", "react", "react-dom", "--save"
            #system "npm", "install", "babel-core", "babel-loader", "babel-preset-es2015", "babel-preset-react", "--save"
            system "npm", "install", "gamefic-driver", "react-gamefic", "--save"
          end
        end

        def start
          Dir.chdir target_dir do
            exec "npm", "run", "start"
          end
        end

        private

        def write_files_to_target src_dir
          binder = Gamefic::Sdk::Binder.new(config, target['name'])
          Dir[File.join(src_dir, '**', '{.*,*}')].each do |file|
            if File.directory?(file)
              FileUtils.mkdir_p File.join(target_dir, file[src_dir.length+1..-1])
            else
              FileUtils.mkdir_p File.join(target_dir, File.dirname(file[src_dir.length+1..-1]))
              if File.extname(file) == '.erb'
                dst = File.join target_dir, file[src_dir.length+1..-5]
                File.write dst, ERB.new(File.read(file)).result(binder.get_binding)
              else
                FileUtils.cp file, File.join(target_dir, file[src_dir.length+1..-1])
              end
            end
          end
        end
      end
    end
  end
end
