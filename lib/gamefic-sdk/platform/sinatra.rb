require 'gamefic'
require 'gamefic-sdk'

module Gamefic::Sdk

  class Platform::Sinatra < Platform::Web
    autoload :AppConfig, 'gamefic-sdk/platform/web/app_config'

    def build
      STDERR.puts "Building for Sinatra"
      FileUtils.mkdir_p release_target
      copy_html_files
      render_index
      copy_assets
      copy_media
      FileUtils.cp_r File.join(Gamefic::Sdk::HTML_TEMPLATE_PATH, 'sinatra', 'engine.js'), File.join(release_target, 'core', 'engine.js')
    end

    #def clean
    #  FileUtils.remove_entry_secure config['build_path'] if File.exist?(config['build_path'])
    #  FileUtils.mkdir_p config['build_path']
    #  puts "#{config['build_path']} cleaned."
    #end

    def app_config
      @app_config ||= AppConfig.new config.source_dir, config, ["core/engine.js"]
    end

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
      Dir.entries(app_config.html_dir).each { |entry|
        if entry != 'index.rb' and entry != 'index.html.erb' and entry != '.' and entry != '..'
          FileUtils.mkdir_p release_target + '/' + File.dirname(entry)
          FileUtils.cp_r "#{app_config.html_dir}/#{entry}", "#{release_target}/#{entry}"
        end
      }
    end

    def render_index
      # Render index
      File.open(release_target + "/index.html", "w") do |file|
        file << app_config.render
      end
    end

    def copy_assets
      paths = app_config.resource_paths
      paths.push build_target
      app_config.javascripts.each { |js|
        absolute = resolve(js, paths)
        FileUtils.mkdir_p release_target + "/" + File.dirname(js)
        FileUtils.cp_r absolute, release_target + "/" + js
      }
      app_config.stylesheets.each { |css|
        absolute = resolve(css, paths)
        FileUtils.mkdir_p release_target + "/" + File.dirname(css)
        FileUtils.cp_r absolute, release_target + "/" + css
      }
    end

=begin
    def copy_media
      # Copy media
      pc = PlotConfig.new "#{source_dir}/config.yaml"
      pc.media_paths.each { |path|
        if File.directory?(path)
          FileUtils.mkdir_p release_target + "/media"
          Dir.entries(path).each { |entry|
            if entry != '.' and entry != '..'
              FileUtils.mkdir_p release_target + "/media/" + File.dirname(entry)
              FileUtils.cp_r path + "/" + entry, release_target + "/media/" + entry
            end
          }
        end
      }
    end
=end

    def metadata_code
      "\nGameficOpal.static_plot.metadata = JSON.parse('#{metadata.to_json}')"
    end
  end

end
