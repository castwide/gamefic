require 'gamefic'
require 'gamefic-sdk'
require 'opal'
require 'uglifier'

module Gamefic::Sdk

  class Platform::Web < Platform::Base
    autoload :AppConfig, 'gamefic-sdk/platform/web/app_config'

    def app_config
      @app_config ||= AppConfig.new config.source_dir, config, ["core/opal.js", "core/gamefic.js", "core/static.js", "core/scripts.js", "core/engine.js"]
    end

    def build
      FileUtils.mkdir_p release_target
      FileUtils.mkdir_p build_target
      copy_html_files
      build_opal_js
      build_gamefic_js
      build_static_js
      build_scripts_js
      render_index
      copy_assets
      copy_media
    end

    def clean
      FileUtils.remove_entry_secure build_target if File.exist?(build_target)
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
          FileUtils.mkdir_p release_target + '/' + File.dirname(entry)
          FileUtils.cp_r "#{app_config.html_dir}/#{entry}", "#{release_target}/#{entry}"
        end
      }
    end

    def build_opal_js
      # Make sure core exists in build directory
      FileUtils.mkdir_p build_target + "/core"
      # Opal core
      if !File.exist?(build_target + "/core/opal.js")
        File.open(build_target + "/core/opal.js", "w") do |file|
          file << Uglifier.compile(
            Opal::Builder.build('opal').to_s + "\n" + Opal::Builder.build('json').to_s + "\n" + Opal::Builder.build('native').to_s
          )
        end
      end
    end

    def build_gamefic_js
      # Gamefic core
      Opal.use_gem 'gamefic'
      if !File.exist?(build_target + "/core/gamefic.js")
        File.open(build_target + "/core/gamefic.js", "w") do |file|
          file << Uglifier.compile(Opal::Builder.build('gamefic').to_s)
        end
      end
    end

    def build_static_js
      Opal.append_path Gamefic::Sdk::LIB_PATH
      if !File.exist?(build_target + "/core/static.js")
        File.open(build_target + "/core/static.js", "w") do |file|
          file << Uglifier.compile(
            Opal::Builder.build('gamefic-sdk/platform/web/engine').to_s + "\n" + Opal::Builder.build('gamefic-sdk/platform/web/user').to_s
          )
        end
      end
    end

    def build_scripts_js
      File.open("#{build_target}/scripts.rb", 'w') do |file|
        file << "module Gamefic\n"
        file << "$scripts = {}\n"
        plot.imported_scripts.each { |script|
          file << "$scripts['#{script.path}'] = proc {\n"
          file << script.read
          file << "\n}\n"
        }
        file << "$source = Gamefic::Source::Text.new($scripts)\n"
        file << "$plot = Gamefic::Plot.new($source)\n"
        file << "$plot.script 'main'\n"
        file << "$engine = Gamefic::Engine::Web.new($plot)\n"
        file << "end\n"
      end
      Opal.append_path build_target
      File.open(build_target + "/core/scripts.js", 'w') do |file|
        file << Uglifier.compile(Opal::Builder.build('scripts').to_s)
      end
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

    def copy_media
      FileUtils.mkdir_p release_target + "/media"
      return unless File.directory?(config.media_path)
      Dir.entries(config.media_path).each { |entry|
        if entry != '.' and entry != '..'
          FileUtils.mkdir_p release_target + "/media/" + File.dirname(entry)
          FileUtils.cp_r config.media_path + "/" + entry, release_target + "/media/" + entry
        end
      }
    end

    def metadata_code
      "\nGameficOpal.static_plot.metadata = JSON.parse('#{metadata.to_json}')"
    end
  end

end
