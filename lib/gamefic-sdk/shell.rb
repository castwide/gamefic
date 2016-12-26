require 'thor'
require 'gamefic-sdk/build'

module Gamefic
  module Sdk
    class Shell < Thor
      autoload :Init, 'gamefic-sdk/shell/init'
      autoload :Test, 'gamefic-sdk/shell/test'

      map %w[--version -v] => :version
      map [:create, :new] => :init
      
      desc "--version, -v", "Print the version"
      def version
        puts "gamefic-sdk #{Gamefic::Sdk::VERSION}"
        puts "gamefic #{Gamefic::VERSION}"
      end

      desc 'init DIRECTORY_NAME', 'Initialize a new game in DIRECTORY_NAME'
      option :quiet, type: :boolean, aliases: :q, desc: 'Suppress output'
      option :standard, type: :boolean, default: true, desc: 'Include the standard script'
      option :scripts, type: :array, aliases: [:s, :script], desc: 'Additional scripts'
      option :webskin, default: 'standard', aliases: [:w], desc: 'Skin to use for the Web platform'
      option :title, type: :string, aliases: [:t], desc: "The game's title"
      option :author, type: :string, aliases: [:a], desc: "The game's author"
      def init(directory_name)
        Gamefic::Sdk::Shell::Init.new(directory: directory_name,
          quiet: options[:quiet], scripts: options[:scripts], webskin: options[:webskin],
          title: options[:title], author: options[:author]).run
      end

      desc 'test DIRECTORY_NAME', 'Play the game in DIRECTORY_NAME'
      def test(directory_name)
        Gamefic::Sdk::Shell::Test.new(directory: directory_name).run
      end

      desc 'build DIRECTORY_NAME', 'Build the game for specified platforms in DIRECTORY_NAME'
      option :quiet, type: :boolean, aliases: :q, desc: 'Suppress output'
      def build(directory_name)
        Gamefic::Sdk::Build.release(directory_name, options[:quiet])
      end

      desc 'clean DIRECTORY_NAME', 'Perform cleanup of DIRECTORY_NAME'
      def clean(directory_name)
        Gamefic::Sdk::Build.clean(directory_name)
      end
      
      desc 'webskins', 'List the available skins for the Web platform'
      def webskins
        Dir[File.join(Gamefic::Sdk::HTML_TEMPLATE_PATH, 'skins', '*')].sort.each { |d|
          puts File.basename(d)
        }
      end
    end
  end
end
