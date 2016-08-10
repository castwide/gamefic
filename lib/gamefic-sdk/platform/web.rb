require 'gamefic'
require 'gamefic-sdk'
require 'opal'

module Gamefic::Sdk

  class Platform::Web < Platform::Base
    autoload :AppConfig, 'gamefic-sdk/platform/web/app_config'
    
    def defaults
      @defaults ||= {
        'html_skin' => 'standard',
        'with_media' => true
      }
    end
    
    def app_config
      @app_config ||= AppConfig.new source_dir, config
    end
    
    def build
      target_dir = config['target_dir']
      build_dir = config['build_dir']
      html_dir = app_config.html_dir
      
      FileUtils.mkdir_p target_dir
      copy_html_files target_dir
      build_opal_js build_dir
      build_gamefic_js build_dir
      build_static_js build_dir
      build_scripts_js build_dir
      render_index target_dir
      copy_assets build_dir, target_dir
      copy_media source_dir, target_dir
      
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
        if entry != 'config.rb' and entry != 'index.html.erb' and entry != '.' and entry != '..'
          FileUtils.mkdir_p target_dir + '/' + File.dirname(entry)
          FileUtils.cp_r "#{app_config.html_dir}/#{entry}", "#{target_dir}/#{entry}"
        end
      }
    end

    def build_opal_js build_dir
      # Make sure core exists in build directory
      FileUtils.mkdir_p build_dir + "/core"
      # Opal core
      if !File.exist?(build_dir + "/core/opal.js")
        File.open(build_dir + "/core/opal.js", "w") do |file|
         file << Opal::Builder.build('opal')
         file << Opal::Builder.build('json')
         file << Opal::Builder.build('native')
        end
      end
    end
    
    def build_gamefic_js build_dir
      # Gamefic core
      Opal.append_path Gamefic::Sdk::LIB_PATH
      if !File.exist?(build_dir + "/core/gamefic.js")
        File.open(build_dir + "/core/gamefic.js", "w") do |file|
         file << Opal::Builder.build('gamefic').to_s
        end
      end
    end
    
    def build_static_js build_dir
      # GameficOpal
      if !File.exist?(build_dir + "/core/static.js")
        File.open(build_dir + "/core/static.js", "w") do |file|
          file << Opal::Builder.build('gamefic-sdk/platform/web/gamefic_opal')
        end
      end
    end
    
    def build_scripts_js build_dir
      # Plot scripts
      File.open("#{build_dir}/scripts.rb", 'w') do |file|
        file << "def GameficOpal.load_scripts\n"
        plot.imported_scripts.each { |script|
          file << "GameficOpal.static_plot.stage do\n"
          file << script.read
          file << "\nend\n"
        }
        file << "end\n"
        #file << metadata
      end
      Opal.append_path build_dir
      File.open(build_dir + "/core/scripts.js", 'w') do |file|
        file << Opal::Builder.build('scripts')
      end
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
  end

end
