require 'opal'
require 'uglifier'

module Gamefic::Sdk

  class Platform::Web < Platform::Base
    autoload :AppConfig, 'gamefic-sdk/platform/web/app_config'

    include Gamefic::Sdk::Platform::OpalBuilder

    # @return [Gamefic::Sdk::Platform::Web::AppConfig]
    def app_config
      @app_config ||= AppConfig.new config.source_dir, config, ["core/jquery.js", "core/opal.js", "core/engine.js", "opal/initialize.js"]
    end

    def build
      FileUtils.mkdir_p target_dir
      FileUtils.mkdir_p build_dir
      copy_html_files
      build_opal_js
      copy_assets
      copy_media
      render_index
    end

    def clean
      FileUtils.remove_entry_secure build_dir if File.exist?(build_dir)
      puts "#{name} cleaned."
    end

    def html_dir
      if @html_dir.nil?
        local_dir = (target['html'] ? target['html'] : 'html')
        @html_dir = Pathname.new(config.source_dir).join(local_dir).to_s
        @html_dir = nil unless Dir.exist?(@html_dir)
        if @html_dir.nil?
          @html_dir = File.join(Gamefic::Sdk::HTML_TEMPLATE_PATH, 'skins', 'standard')
        end
      end
      @html_dir
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
      #Dir.entries(app_config.html_dir).each { |entry|
      Dir.entries(html_dir).each { |entry|
        if entry != 'index.rb' and entry != 'index.html.erb' and entry != '.' and entry != '..'
          FileUtils.mkdir_p build_dir + '/' + File.dirname(entry)
          #FileUtils.cp_r "#{app_config.html_dir}/#{entry}", "#{build_dir}/#{entry}"
          FileUtils.cp_r File.join(target_dir, entry), File.join(build_dir, entry)
        end
      }
    end

    def build_opal_js
      FileUtils.mkdir_p File.join(build_dir, 'core')
      File.write File.join(build_dir, 'core', 'opal.js'), Uglifier.compile(build_opal_str)
    end

    def render_index
      # Render index
      File.open(build_dir + "/index.html", "w") do |file|
        file << config.render(File.join(target_dir, 'index.html.erb'))
      end
    end

    def copy_assets
      paths = app_config.resource_paths
      paths.push target_dir
      app_config.javascripts.each { |js|
        unless File.exist?(File.join(build_dir, js))
          absolute = resolve(js, paths)
          FileUtils.mkdir_p File.join(build_dir, File.dirname(js))
          FileUtils.cp_r absolute, File.join(build_dir, js)
        end
      }
      app_config.stylesheets.each { |css|
        absolute = resolve(css, paths)
        FileUtils.mkdir_p build_dir + "/" + File.dirname(css)
        FileUtils.cp_r absolute, build_dir + "/" + css
      }
    end

    def copy_media
      FileUtils.mkdir_p build_dir + "/media"
      return unless File.directory?(config.media_path)
      Dir.entries(config.media_path).each { |entry|
        if entry != '.' and entry != '..'
          FileUtils.mkdir_p build_dir + "/media/" + File.dirname(entry)
          FileUtils.cp_r config.media_path + "/" + entry, build_dir + "/media/" + entry
        end
      }
    end
  end

end
