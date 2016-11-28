require 'thor'
require 'gamefic-sdk/build'

module Gamefic
  module Sdk
    class Shell < Thor
      autoload :Init, 'gamefic-sdk/shell/init'
      autoload :Test, 'gamefic-sdk/shell/test'

      desc 'init DIRECTORY_NAME', 'Initialize a new game in DIRECTORY_NAME'
      option :quiet, type: :boolean, aliases: :q, desc: 'Suppress output'
      def init(directory_name)
        Gamefic::Sdk::Shell::Init.new(directory: directory_name, quiet: options[:quiet]).run
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
    end
  end
end
