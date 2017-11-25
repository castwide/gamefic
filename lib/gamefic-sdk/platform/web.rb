require 'opal'
require 'uglifier'

module Gamefic::Sdk

  class Platform::Web < Platform::Base
    include Gamefic::Sdk::Platform::OpalBuilder

    def build
      FileUtils.mkdir_p build_dir
      copy_html_files
      build_opal_js
      copy_assets
      copy_media
      render_index
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

    def make_target
      FileUtils.mkdir_p target_dir
      FileUtils.cp_r(Dir[Gamefic::Sdk::HTML_TEMPLATE_PATH + '/skins/' + 'standard' + '/*'], target_dir)
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
      Dir.entries(html_dir).each do |entry|
        if entry != 'index.rb' and entry != 'index.html.erb' and entry != '.' and entry != '..'
          FileUtils.mkdir_p File.join(build_dir, File.dirname(entry))
          FileUtils.cp_r File.join(html_dir, entry), File.join(build_dir, entry)
        end
      end
    end

    def build_opal_js
      FileUtils.mkdir_p File.join(build_dir, 'core')
      File.write File.join(build_dir, 'core', 'opal.js'), Uglifier.compile(build_opal_str)
    end

    def render_index
      template = File.join(html_dir, 'index.html.erb')
      if File.exist?(template)
        File.write File.join(build_dir, 'index.html'), config.render(template)
      end
    end

    def copy_assets
      paths = [html_dir, Gamefic::Sdk::HTML_TEMPLATE_PATH]
      paths.push target_dir
      javascripts.each do |js|
        unless File.exist?(File.join(build_dir, js))
          absolute = resolve(js, paths)
          FileUtils.mkdir_p File.join(build_dir, File.dirname(js))
          FileUtils.cp_r absolute, File.join(build_dir, js)
        end
      end
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

  def javascripts
    @javascripts ||= ["core/jquery.js", "core/opal.js", "core/engine.js", "opal/initialize.js"]
  end
end
