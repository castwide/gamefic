require 'yaml'

module Gamefic::Sdk
  
  class PlotConfig
    attr_reader :author, :title, :script_paths, :media_paths
    def initialize filename = nil
      @script_paths = []
      @media_paths = []
      if !filename.nil?
	      config = YAML.load_file filename
	      base_dir = File.dirname(filename)
	      @author = config['author']
	      @title = config['title']
	      config['script_paths'].each { |p|
	        @script_paths.push File.absolute_path(p, base_dir)
	      } if !config['script_paths'].nil?
	      config['media_paths'].map! { |p|
	        @media_paths.push File.absolute_path(p, base_dir)
	      } if !config['media_paths'].nil?
      end
    end
  end
  
end
