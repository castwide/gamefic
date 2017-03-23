require 'gamefic'
require 'gamefic-sdk'

module Gamefic::Sdk

  class Platform::Sinatra < Platform::Web
    autoload :AppConfig, 'gamefic-sdk/platform/web/app_config'

    def build
      STDERR.puts "Building for Sinatra"
      target_dir = config['target_dir']
      build_dir = config['build_dir']
      html_dir = app_config.html_dir

      FileUtils.mkdir_p target_dir
      copy_html_files target_dir
      render_index target_dir
      copy_assets build_dir, target_dir
      copy_media source_dir, target_dir
      FileUtils.cp_r File.join(Gamefic::Sdk::HTML_TEMPLATE_PATH, 'sinatra', 'engine.js'), File.join(target_dir, 'core', 'engine.js')
    end

    def clean
      FileUtils.remove_entry_secure config['build_dir'] if File.exist?(config['build_dir'])
      FileUtils.mkdir_p config['build_dir']
      puts "#{config['build_dir']} cleaned."
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
    def copy_html_files target_dir
      Dir.entries(app_config.html_dir).each { |entry|
        if entry != 'index.rb' and entry != 'index.html.erb' and entry != '.' and entry != '..'
          FileUtils.mkdir_p target_dir + '/' + File.dirname(entry)
          FileUtils.cp_r "#{app_config.html_dir}/#{entry}", "#{target_dir}/#{entry}"
        end
      }
    end

    def render_index target_dir
      # Render index
      File.open(target_dir + "/index.html", "w") do |file|
        file << app_config.render
      end
    end

    def copy_assets build_dir, target_dir
      paths = app_config.resource_paths
      paths.push build_dir
      app_config.javascripts.each { |js|
        absolute = resolve(js, paths)
        FileUtils.mkdir_p target_dir + "/" + File.dirname(js)
        FileUtils.cp_r absolute, target_dir + "/" + js
      }
      app_config.stylesheets.each { |css|
        absolute = resolve(css, paths)
        FileUtils.mkdir_p target_dir + "/" + File.dirname(css)
        FileUtils.cp_r absolute, target_dir + "/" + css
      }
    end

    def copy_media source_dir, target_dir
      # Copy media
      pc = PlotConfig.new "#{source_dir}/config.yaml"
      pc.media_paths.each { |path|
        if File.directory?(path)
          FileUtils.mkdir_p target_dir + "/media"
          Dir.entries(path).each { |entry|
            if entry != '.' and entry != '..'
              FileUtils.mkdir_p target_dir + "/media/" + File.dirname(entry)
              FileUtils.cp_r path + "/" + entry, target_dir + "/media/" + entry
            end
          }
        end
      }
    end

    def metadata_code
      "\nGameficOpal.static_plot.metadata = JSON.parse('#{metadata.to_json}')"
    end
  end

end
