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
      
      copy_web_assets build_dir, target_dir
      
      if !File.exist?(build_dir + "/opal.js")
        File.open(build_dir + "/opal.js", "w") do |file|
         file << Opal::Builder.build('opal')
         file << Opal::Builder.build('json')
         file << Opal::Builder.build('native')
        end
      end
      
      Opal.append_path Gamefic::Sdk::LIB_PATH
      if !File.exist?(build_dir + "/gamefic.js")
        File.open(build_dir + "/gamefic.js", "w") do |file|
         file << Opal::Builder.build('gamefic').to_s
        end
      end

      File.open("#{build_dir}/scripts.rb", 'w') do |file|
        #file << "module GameficOpal\n"
        file << "def GameficOpal.load_scripts\n"
        plot.imported_scripts.each { |script|
          file << "GameficOpal.static_plot.stage do\n"
          file << script.read
          file << "\nend\n"
        }
        file << "end\n"
        #file << "end\n"
      end
      
      Opal.append_path Gamefic::Sdk::HTML_TEMPLATE_PATH + "/src"
      File.open(build_dir + "/static.js", "w") do |file|
        file << Opal::Builder.build('static')
      end
      
      Opal.append_path build_dir
      File.open(target_dir + "/scripts.js", 'w') do |file|
        file << Opal::Builder.build('scripts')
      end
      FileUtils.cp build_dir + "/opal.js", target_dir + "/opal.js"
      FileUtils.cp build_dir + "/gamefic.js", target_dir + "/gamefic.js"
      FileUtils.cp build_dir + "/static.js", target_dir + "/static.js"
    end
    
    def clean
      FileUtils.remove_entry_secure config['build_dir'] if File.exist?(config['build_dir'])
      FileUtils.mkdir_p config['build_dir']
      puts "#{config['build_dir']} cleaned."
    end
    
    private
    
    def copy_web_assets build_dir, target_dir
      # Copy all web assets (HTML files, etc.)
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
    end
    
  end

end
