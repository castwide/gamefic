require 'sinatra/base'

module Gamefic
  module Sdk

    class Server < Sinatra::Base
      set :port, 4342
      
      get '/' do
        paths = config_path(settings.root).script_paths + [Gamefic::Sdk::GLOBAL_SCRIPT_PATH]
        @@plot = Gamefic::Sdk::Debug::Plot.new Source::File.new(*paths)
        @@plot.script 'main'
        @@plot.script 'debug'
        File.read File.join('public', 'index.html')
      end

      post '/start' do
        @@character = Character.new(name: 'player', synonyms: 'me myself self you yourself', description: 'As good-looking as ever.')
        @@character.connect User::Base.new
        @@plot.introduce @@character
        @@plot.ready
        @@character.user.flush
      end

      post '/update' do
        @@character.queue.push params['command']
        @@plot.update
        @@plot.ready
        @@character.user.flush
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
