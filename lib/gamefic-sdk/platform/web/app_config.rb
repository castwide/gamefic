require 'erb'
require 'gamefic/stage'

class Gamefic::Sdk::Platform::Web::AppConfig
  include Stage
  attr_reader :javascripts, :stylesheets, :resource_paths
  expose :javascripts, :stylesheets, :resource_paths
  
  # @param main_dir [String] The directory containing the resources (config file, HTML template, etc.) for this build
  def initialize source_dir
    @javascripts = []
    @stylesheets = []
    @source_dir = source_dir
    @resource_paths = ["#{source_dir}", Gamefic::Sdk::HTML_TEMPLATE_PATH]
    config_file = "#{source_dir}/config.rb"
    stage File.read(config_file), config_file
  end
  
  # @return [BuildConfig::Data]
  def data
    Data.new @javascripts, @stylesheets
  end
  
  # Render HTML using the build config data
  #
  # @return [String] The resulting HTML
  def render
    erb = ERB.new(File.read(@source_dir + "/index.erb"))
    erb.result data.get_binding
  end
end

class Gamefic::Sdk::Platform::Web::AppConfig::Data
  attr_reader :javascripts, :stylesheets
  def initialize javascripts, stylesheets
    @javascripts = javascripts
    @stylesheets = stylesheets
  end
  def javascript_tags
    result = ""
    javascripts.each { |js|
      result += "<script type=\"text/javascript\" src=\"#{js}\"></script>"
    }
    result
  end
  def stylesheet_tags
    result = ""
    stylesheets.each { |css|
      result += "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{css}\" />"
    }
    result
  end
  def get_binding
    binding()
  end
end
