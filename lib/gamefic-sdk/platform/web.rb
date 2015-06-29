require 'gamefic'
require 'gamefic-sdk'
require 'opal'

module Gamefic::Sdk

  class Web < Platform
    def defaults
      @@defaults ||= {
        :html_skin => 'multimedia',
        :with_media => true
      }
    end
    def build source_dir, target_dir, plot
      build_dir = source_dir + "/build/web"
      build_path = build_dir
      main = nil
      ['plot','rb'].each { |e|
        if File.file?(source_dir + '/main.' + e)
          main = source_dir + '/main.' + e
          break
        end
      }
      FileUtils.mkdir_p build_dir if !File.exist?(build_dir)
      FileUtils.remove_entry_secure target_dir if File.exist?(target_dir)
      FileUtils.mkdir_p target_dir
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
      
      File.open(build_path + "/static.js", "w") do |file|
        file << Opal.compile(File.read(Gamefic::Sdk::HTML_TEMPLATE_PATH + "/src/static.rb"))
      end

      plot = Plot.new(Source.new(GLOBAL_IMPORT_PATH))
      plot.load main

      imported = []
      
      plot.imported_scripts.each { |script|
        import_js = "import/" + File.dirname(script.relative) + File.basename(script.relative, File.extname(script.relative)) + ".js"
        if !File.exist?(build_dir + "/" + import_js) or File.mtime(build_dir + "/" + import_js) < File.mtime(script.absolute)
          FileUtils.mkdir_p(build_dir + "/import/" + File.dirname(script.relative))
          File.open(build_dir + "/" + import_js, "w") do |file|
            file << Opal.compile("module Gamefic;static_plot.instance_eval do; #{File.read(script.absolute).gsub(/import [^\n]*/, '')} ;end;end\n")
          end
        end
        imported.push import_js
      }
      
      if !File.exist?(build_dir + "/main.js") or File.mtime(build_dir + "/main.js") < File.mtime(main)
        File.open(build_dir + "/main.js", "w") do |file|
          file << Opal.compile("module Gamefic;static_plot.instance_eval do; #{File.read(main).gsub(/import [^\n]*/, '')} ;end;end\n")
        end
      end
      imported.push "main.js"
      
      FileUtils.cp build_path + "/opal.js", target_dir + "/opal.js"
      FileUtils.cp build_path + "/gamefic.js", target_dir + "/gamefic.js"
      FileUtils.cp build_path + "/static.js", target_dir + "/static.js"
      script_code = ""
      imported.each { |file|
        script_code += File.read(build_path + "/" + file)
      }
      File.open(target_dir + "/game.js", "w") do |file|
        file << script_code
      end
    end
    def clean build_dir, target_dir
      FileUtils.remove_entry_secure build_dir if File.exist?(build_dir)
      FileUtils.mkdir_p build_dir
      puts "#{build_dir} cleaned."
    end
  end

end
