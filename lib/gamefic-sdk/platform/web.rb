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
      main = source_dir + '/main.rb'
      FileUtils.remove_entry_secure target_dir if File.exist?(target_dir)
      FileUtils.mkdir_p target_dir
      if config[:html_skin].to_s != ''
        skin = Gamefic::Sdk::HTML_TEMPLATE_PATH + "/skins/#{config[:html_skin]}"
        if File.directory?(skin)
          FileUtils.cp_r(Dir[Gamefic::Sdk::HTML_TEMPLATE_PATH + "/core/*"], target_dir)
          FileUtils.cp_r(Dir["#{skin}/*"], target_dir)
        end
      end
      FileUtils.cp_r(Dir["#{source_dir}/media/*"], target_dir) if File.directory?("#{source_dir}/media")
      FileUtils.cp_r(Dir["#{source_dir}/html/*"], target_dir) if File.directory?("#{source_dir}/html")
      code = <<EOS
require 'opal'
require "gamefic/core_ext/array"
require "gamefic/core_ext/string"
require "gamefic/optionset"
require "gamefic/keywords"
require "gamefic/entity"
require "gamefic/character"
require "gamefic/character/state"
require "gamefic/action"
require "gamefic/meta"
require "gamefic/syntax"
require "gamefic/query"
require "gamefic/rule"
require "gamefic/director"
require "gamefic/plot"
require "gamefic/engine"
require "gamefic/direction"
module Gamefic
  GLOBAL_IMPORT_PATH = "/home/fred/gamefic/import"
  def self.plot
    @@plot ||= Gamefic::Plot.new
  end
  def self.player
    @@player ||= User.new(self.plot)
  end
  def self.method_missing(method_name, *args, &block)
    if self.plot.respond_to?(method_name)
     self.plot.send method_name, *args, &block
    elsif Gamefic.respond_to?(method_name)
      Gamefic.send method_name, *args, &block
    else
      raise "Unknown method " + method_name + " in plot script"
    end
  end
EOS
      plot.imported_scripts.each { |import|
        code += "#" + import.absolute + "\n"
        code += File.read(import.absolute).gsub(/import [^\n]*/, '') + "\n"
      }
      code += "#" + main + "\n"
      code += File.read(main).gsub(/import [^\n]*/, '') + "\n"
      code += <<EOS
end
EOS
      Opal::Processor.source_map_enabled = true
      env = Opal::Environment.new
      env.append_path target_dir
      env.append_path "/home/fred/gamefic/lib"
      File.open("#{target_dir}/game.rb", "w") do |out|
        out << code
      end
      engine_js = env["game"].to_s
      engine_js += <<EOS
var Gamefic = Gamefic || {};
Gamefic.Engine = new function() {
  var begun = false;
  this.run = function(command, callback) {
    var response = {};
    if (!begun) {
      begun = true;
      Opal.Gamefic.$plot().$introduce(Opal.Gamefic.$player().$character());
      Opal.Gamefic.$plot().$update();
      response.output = Opal.Gamefic.$player().$state().$output();
    } else {
        Opal.Gamefic.$player().$character().$queue().$push(command);
        while (Opal.Gamefic.$player().$character().$queue().$length() > 0) {
          Opal.Gamefic.$player().$character().$state().$accept(Opal.Gamefic.$player().$character(), Opal.Gamefic.$player().$character().$queue().$pop());
        }
        Opal.Gamefic.$plot().$update();
        response.output = Opal.Gamefic.$player().$state().$output();
    }
    response.prompt = Opal.Gamefic.$player().$character().$state().$prompt();
    response.command = command;
    response.state = Opal.Gamefic.$player().$character().$state().$class().$to_s().split('::').pop();
    callback(response);
  }
}
EOS
      File.open("#{target_dir}/engine.js", "w") do |out|
        out << engine_js
      end
      FileUtils.remove_entry_secure "#{target_dir}/game.rb"
      vars = {
        "title" => config[:title],
        "author" => config[:author]
      }
      Dir["#{target_dir}/*.html"].each { |file|
        source = File.read(file)
        source.gsub!(/\{\{([a-z0-9_]*)\}\}/i) { |match|
          vars[$1]
        }
        File.open(file, 'w') do |out|
          out << source
        end
      }
    end
  end

end
