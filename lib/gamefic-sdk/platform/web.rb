require 'gamefic'
require 'gamefic-sdk'
require 'opal'

module Gamefic::Sdk

  class Platform::Web < Platform::Base
    def defaults
      @defaults ||= {
        :html_skin => 'multimedia',
        :with_media => true
      }
    end
    def build
      target_dir = config['target_dir']
      # TODO Configurable build folder?
      build_dir = config['build_dir']
      build_path = build_dir
      main = nil
      ['plot','rb'].each { |e|
        if File.file?(source_dir + '/main.' + e)
          main = source_dir + '/main.' + e
          break
        end
      }
      FileUtils.mkdir_p build_dir if !File.exist?(build_dir)
      FileUtils.rm_r Dir.glob("#{target_dir}/*") if File.exist?(target_dir)
      FileUtils.mkdir_p target_dir if !File.exist?(target_dir)
      FileUtils.cp_r(Dir[Gamefic::Sdk::HTML_TEMPLATE_PATH + "/core/*"], target_dir)
      if config[:html_skin].to_s != ''
        skin = nil
        if File.directory?(Gamefic::Sdk::HTML_TEMPLATE_PATH + "/skins/#{config[:html_skin]}")
          skin = Gamefic::Sdk::HTML_TEMPLATE_PATH + "/skins/#{config[:html_skin]}"
        else
          raise "HTML skin directory '#{config[:html_skin]}' not found"
        end
        if File.directory?(skin)
          FileUtils.cp_r(Dir["#{skin}/*"], target_dir)
        end
      end
      FileUtils.cp_r(Dir["#{source_dir}/media/*"], target_dir) if File.directory?("#{source_dir}/media")
      FileUtils.cp_r(Dir["#{source_dir}/html/*"], target_dir) if File.directory?("#{source_dir}/html")

      Opal.append_path Gamefic::Sdk::LIB_PATH

      if !File.exist?(build_path + "/opal.js")
        File.open(build_path + "/opal.js", "w") do |file|
         file << Opal::Builder.build('opal')
         file << Opal::Builder.build('json')
         file << Opal::Builder.build('native')
        end
      end
      
      if !File.exist?(build_path + "/gamefic.js")
        File.open(build_path + "/gamefic.js", "w") do |file|
         file << Opal::Builder.build('gamefic').to_s
        end
      end
      
      Opal.append_path Gamefic::Sdk::HTML_TEMPLATE_PATH + "/src"
      
      imported = []
      
      plot.imported_scripts.each { |script|
        import_js = "scripts/" + File.dirname(script.relative) + "/" + File.basename(script.relative, File.extname(script.relative)) + ".rb"
        if !File.exist?(build_dir + "/" + import_js) or File.mtime(build_dir + "/" + import_js) < File.mtime(script.absolute)
          FileUtils.mkdir_p(build_dir + "/scripts/" + File.dirname(script.relative))
          File.open(build_dir + "/" + import_js, "w") do |file|
            file << "require 'gamefic';module Gamefic;"  + File.read(script.absolute) + ";end"
            file << "\n"
          end
        end
        imported.push import_js
      }
      
      if !File.exist?(build_dir + "/main.js") or File.mtime(build_dir + "/main.js") < File.mtime(main)
        File.open(build_dir + "/main.rb", "w") do |file|
          file << "require 'gamefic';module Gamefic;" + File.read(main) + ";end"
          file << "\n"
        end
      end
      imported.push "main.js"
      
      Opal.append_path build_dir
      Opal.append_path build_dir + "/scripts"
      
      File.open(build_path + "/static.js", "w") do |file|
        file << Opal::Builder.build('static')
      end
      
      FileUtils.cp build_path + "/opal.js", target_dir + "/opal.js"
      FileUtils.cp build_path + "/gamefic.js", target_dir + "/gamefic.js"
      FileUtils.cp build_path + "/static.js", target_dir + "/static.js"
    end
    def clean
      FileUtils.remove_entry_secure config['build_dir'] if File.exist?(config['build_dir'])
      FileUtils.mkdir_p config['build_dir']
      puts "#{config['build_dir']} cleaned."
    end
  end

end
