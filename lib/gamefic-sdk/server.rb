require 'sinatra/base'
require 'yaml'

module Gamefic
  module Sdk

    class Server < Sinatra::Base
      set :port, 4342
      
      get '/' do
        paths = base_build(settings.source_dir).script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
        #config = YAML.load(File.read(File.join(settings.source_dir, 'config.yaml')))
        #config['name'] = 'sinatra'
        @@plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
        @@plot.script 'main'
        @@plot.script 'debug'
        #sinatra = Gamefic::Sdk::Platform::Sinatra.new(settings.source_dir, 'sinatra', base_build(settings.source_dir).config)
        sinatra = Gamefic::Sdk::Platform::Sinatra.new(config: base_build(settings.source_dir))
        sinatra.build
        File.read File.join(sinatra.release_target, 'index.html')
      end

      post '/start' do
        content_type :json
        @@character = @@plot.player_class.new(name: 'player', synonyms: 'me myself self you yourself', description: 'As good-looking as ever.')
        #@@character.connect User::Base.new
        #connect
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

      private

      #def config_path dir
        #if File.directory?(dir)
        #  PlotConfig.new File.join(dir, 'config.yaml')
        #else
        #  PlotConfig.new
        #end

      #end

      def base_build dir
        #yaml = YAML.load(File.read("#{dir}/config.yaml"))
        #puts yaml.inspect
        #Gamefic::Sdk::Platform::Base.new(dir, 'sinatra', yaml)
        #Gamefic::Sdk::Platform::B
        Gamefic::Sdk::Config.load dir
      end
    end

  end
end
