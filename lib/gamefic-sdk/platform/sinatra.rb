require 'gamefic'
require 'gamefic-sdk'

module Gamefic::Sdk

  class Platform::Sinatra < Platform::Web
    #autoload :AppConfig, 'gamefic-sdk/platform/web/app_config'

    def build
      STDERR.puts "Building for Sinatra"
      FileUtils.mkdir_p build_dir
      copy_html_files
      render_index
      copy_assets
      copy_media
      #FileUtils.cp_r File.join(Gamefic::Sdk::HTML_TEMPLATE_PATH, 'core', 'engine.js'), File.join(build_dir, 'core', 'engine.js')
    end

    #def app_config
    #  @app_config ||= AppConfig.new config.source_dir, config, ["core/engine.js", "sinatra/initialize.js"]
    #end

    private

    def resolve filename, paths
      absolute = nil
      paths.each { |path|
        if File.file?("#{path}/#{filename}")
          absolute = File.join(path, filename)
          break
        end
      }
      raise "#{filename} not found" if absolute.nil?
      absolute
    end

    # Copy everything in source except config and template
    def copy_html_files
      Dir.entries(html_dir).each { |entry|
        if entry != 'index.rb' and entry != 'index.html.erb' and entry != '.' and entry != '..'
          FileUtils.mkdir_p build_dir + '/' + File.dirname(entry)
          FileUtils.cp_r "#{html_dir}/#{entry}", "#{build_dir}/#{entry}"
        end
      }
    end

    def copy_assets
      return
      paths = app_config.resource_paths
      paths.push build_target
      app_config.javascripts.each { |js|
        absolute = resolve(js, paths)
        FileUtils.mkdir_p build_dir + "/" + File.dirname(js)
        FileUtils.cp_r absolute, build_dir + "/" + js
      }
      app_config.stylesheets.each { |css|
        absolute = resolve(css, paths)
        FileUtils.mkdir_p build_dir + "/" + File.dirname(css)
        FileUtils.cp_r absolute, build_dir + "/" + css
      }
    end

    def metadata_code
      "\nGameficOpal.static_plot.metadata = JSON.parse('#{metadata.to_json}')"
    end
  end

end
