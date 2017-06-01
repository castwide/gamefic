require 'sinatra/base'
require 'yaml'

module Gamefic
  module Sdk

    class Server < Sinatra::Base
      set :port, 4342

      get '/' do
        config = Gamefic::Sdk::Config.load(settings.source_dir)
        paths = [config.script_path, config.import_path, Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
        @@plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
        @@plot.script 'main'
        @@plot.script 'debug'
        sinatra = Gamefic::Sdk::Platform::Sinatra.new(config: config)
        sinatra.build
        File.read File.join(sinatra.release_target, 'index.html')
      end

      post '/start' do
        content_type :json
        @@character = @@plot.player_class.new(name: 'player', synonyms: 'me myself self you yourself', description: 'As good-looking as ever.')
        @@plot.introduce @@character
        @@plot.ready
        @@character.state.to_json
      end

      post '/update' do
        content_type :json
        @@character.queue.push params['command']
        @@plot.update
        @@plot.ready
        @@character.state.merge(input: params['command']).to_json
      end

      post '/restore' do
        content_type :json
        snapshot = JSON.parse(params['snapshot'], symbolize_names: true)
        STDERR.puts "Restoring: #{snapshot}"
        @@plot.restore snapshot
        @@plot.ready
        @@character.state.to_json
      end

      class << self

        def run!
          start_browser if settings.browser
          super
        end
        
        def start_browser
          Thread.new {
            sleep 1 until Server.running?
            `start http://localhost:#{settings.port}`
          }
        end

      end
    end

  end
end
