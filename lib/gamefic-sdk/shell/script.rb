require 'securerandom'
require 'fileutils'

module Gamefic
  module Sdk
    class Shell
      class Script
        include Gamefic::Sdk::Shell::Plotter

        def initialize path = nil
          @path = path
        end
        def run
          if @path.nil?
            s = []
            config = Gamefic::Sdk::Config.load('.')
            ([config.script_path, config.import_path] + config.library_paths).each do |path|
              Dir[File.join path, '**', '*.rb'].each do |f|
                c = File.read(f)
                c.each_line { |l|
                  match = l.match(/[\s]*#[\s]*@gamefic.script[ ]+([a-z0-9_\/\-]+)/)
                  unless match.nil?
                    s.push(match[1])
                  end
                }
              end
            end
            puts s.uniq.sort.join("\n")
          else
            document_script @path
          end
        end
        private
        
        def document_script path
          begin
            config = Gamefic::Sdk::Config.load('.')
            source = Gamefic::Source::File.new(*([config.script_path, config.import_path] + config.library_paths))
            script = source.export(path)
            c = File.read(script.absolute_path)
            doc = ''
            in_comment = false
            c.each_line { |l|
              if in_comment
                break unless l.start_with?('#')
                doc += "#{l[2..-1]}"
              else
                match = l.match(/[\s]*#[\s]*@gamefic.script[ ]+([a-z0-9\/]+)/)
                in_comment = true unless match.nil?
              end
            }
            if in_comment
              puts ''
              puts path
              puts ''
              puts doc unless doc == ''
              puts '' unless doc == ''
            else
              puts "Path '#{path}' is not documented."
            end
          # @todo More specific exception
          rescue LoadError => e
            puts "Path #{path} not found."
          end
        end
      end
    end
  end
end
