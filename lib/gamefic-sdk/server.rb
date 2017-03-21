require 'sinatra/base'
require 'yaml'

module Gamefic
  module Sdk

    class Server < Sinatra::Base
      set :port, 4342
      
      get '/' do
        paths = config_path(settings.source_dir).script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
        config = YAML.load(File.read(File.join(settings.source_dir, 'config.yaml')))
        config['name'] = 'sinatra'
        @@plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
        @@plot.script 'main'
        @@plot.script 'debug'
        sinatra = Gamefic::Sdk::Platform::Sinatra.new(settings.source_dir, config)
        sinatra.build
        STDERR.puts "#{sinatra.config}"
        File.read File.join(sinatra.config['target_dir'], 'index.html')
      end

      post '/start' do
        STDERR.puts "Server got start post!"
        content_type :json
        @@character = Character.new(name: 'player', synonyms: 'me myself self you yourself', description: 'As good-looking as ever.')
        @@character.connect User::Base.new
        @@plot.introduce @@character
        @@plot.ready
        {
          output: @@character.user.flush,
          prompt: @@character.prompt,
          state: @@character.scene.type,
          input: ''
        }.to_json
      end

      post '/update' do
        STDERR.puts "Processing #{params['command']}"
        content_type :json
        @@character.queue.push params['command']
        @@plot.update
        @@plot.ready
        response = {
          output: @@character.user.flush,
          prompt: @@character.prompt,
          state: @@character.scene.type,
          input: params['command']
        }
        response.to_json
      end

      private

      def config_path dir
        if File.directory?(dir)
          PlotConfig.new File.join(dir, 'config.yaml')
        else
          PlotConfig.new
        end
      end
    end
  
  end
end
