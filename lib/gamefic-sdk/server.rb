require 'sinatra/base'
require 'yaml'
require 'gamefic-sdk/platform/sinatra/user'

module Gamefic
  module Sdk

    class Server < Sinatra::Base
      set :port, 4342

      get '/' do
        config = Gamefic::Sdk::Config.load(settings.source_dir)
        paths = [config.script_path, config.import_path]
        @@plot = Gamefic::Plot.new Source::File.new(*paths)
        @@plot.script 'main'
        #@@plot.script 'debug'
        sinatra = Gamefic::Sdk::Platform::Sinatra.new(config: config)
        sinatra.build
        File.read File.join(settings.public_folder, 'index.html')
      end

      post '/start' do
        content_type :json
        @@character = @@plot.get_player_character
        engine = Gamefic::Engine::Base.new(@@plot)
        @@plot.authorize Gamefic::User::Sinatra.new(engine), @@character
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
        @@plot.restore snapshot
        @@character.cue @@plot.default_scene
        @@plot.update
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
