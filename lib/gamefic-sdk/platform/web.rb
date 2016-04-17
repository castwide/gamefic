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
    
    def build
      target_dir = config['target_dir']
      # TODO Configurable build folder?
      build_dir = config['build_dir']
      app_config = AppConfig.new source_dir, config
      html_dir = app_config.html_dir
      
      FileUtils.mkdir_p target_dir

      # Copy everything in source except config and template
      Dir.entries(html_dir).each { |entry|
        if entry != 'config.rb' and entry != 'index.html.erb' and entry != '.' and entry != '..'
          FileUtils.mkdir_p target_dir + File.dirname(entry)
          FileUtils.cp_r "#{html_dir}/#{entry}", "#{target_dir}/#{entry}"
        end
      }

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
      
      # Gamefic core
      Opal.append_path Gamefic::Sdk::LIB_PATH
      if !File.exist?(build_dir + "/core/gamefic.js")
        File.open(build_dir + "/core/gamefic.js", "w") do |file|
         file << Opal::Builder.build('gamefic').to_s
        end
      end
      
      # GameficOpal
      if !File.exist?(build_dir + "/core/static.js")
	      File.open(build_dir + "/core/static.js", "w") do |file|
	        file << Opal::Builder.build('gamefic-sdk/platform/web/gamefic_opal')
	      end
      end
      
      # Plot scripts
      File.open("#{build_dir}/scripts.rb", 'w') do |file|
        file << "def GameficOpal.load_scripts\n"
        plot.imported_scripts.each { |script|
          file << "GameficOpal.static_plot.stage do\n"
          file << script.read
          file << "\nend\n"
        }
        file << "end\n"
      end
      Opal.append_path build_dir
      File.open(build_dir + "/core/scripts.js", 'w') do |file|
        file << Opal::Builder.build('scripts')
      end

      # Render index
      File.open(target_dir + "/index.html", "w") do |file|
        file << app_config.render
      end

      # Copy requisite assets
      app_config.resource_paths.push build_dir
      app_config.javascripts.each { |js|
        absolute = resolve(js, app_config.resource_paths)
        FileUtils.mkdir_p target_dir + "/" + File.dirname(js)
        FileUtils.cp_r absolute, target_dir + "/" + js
      }
      app_config.stylesheets.each { |css|
        absolute = resolve(css, app_config.resource_paths)
        FileUtils.mkdir_p target_dir + "/" + File.dirname(css)
        FileUtils.cp_r absolute, target_dir + "/" + css
      }
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
          absolute = "#{path}/#{filename}"
          break
        end
      }
      raise "#{filename} not found" if absolute.nil?
      absolute
    end
    
  end

end
