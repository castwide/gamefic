require 'sinatra/base'
require 'yaml'

module Gamefic
  module Sdk

    class Server < Sinatra::Base
      set :port, 4342

      get '/' do
        config = Gamefic::Sdk::Config.load(settings.source_dir)
        paths = [config.script_path, config.import_path]
        @@plot = Gamefic::Plot.new Source::File.new(*paths)
        @@plot.script 'main'
        index_file = File.join(settings.public_folder, 'index.html')
        if File.file?(index_file)
          File.read index_file
        else
          ''
        end
      end

      get '/core/opal.js' do
        ''
      end

      get '/media/:file' do
        send_file File.join(settings.media_folder, params[:file]), disposition: 'inline'
      end

      post '/start' do
        content_type :json
        @@character = @@plot.get_player_character
        engine = Gamefic::Engine::Base.new(@@plot)
        ##@@plot.authorize Gamefic::User::Sinatra.new(engine), @@character
        @@plot.authorize Gamefic::User::Base.new(engine), @@character
        @@plot.introduce @@character
        @@plot.ready
        @@character.state.to_json
      end

      post '/receive' do
        content_type :json
        @@character.queue.push params['command']
        {}.to_json
      end

      post '/update' do
        content_type :json
        @@plot.update
        @@plot.ready
        @@character.state.merge(input: params['command'], continued: @@character.queue.any?).to_json
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
