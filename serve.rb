#!/usr/bin/env ruby

require "core/game.rb"
require "socket"

module Gamefic
	class OnlinePlayer < Player
		attr_writer :socket
		def tell msg
			@socket.send("#{msg.strip}\n\0", 0)
		end
	end
end

module Gamefic
	class Server
		def initialize
			@serverSocket = TCPServer.new('', 4141)
			@descriptors = Array.new
			@descriptors.push(@serverSocket)
			@users = Hash.new
		end
		def run
			while (true)
				resp = select(@descriptors, nil, nil, 0.001)
				if (resp != nil)
					for s in resp[0]
						if (s == @serverSocket)
							# New connection
							n = @serverSocket.accept
							puts ("Connection accepted from #{n.peeraddr[3]}")
							@descriptors.push(n)
							@users[n] = OnlinePlayer.create(
								:name => "player #{n}",
								:parent => Theater.instance.entities.that_are(Room)[0],
								:socket => n
							)
						else
							begin
								req = s.recv(255)
								if (req == '')
									puts ("Disconnecting user at #{n.peeraddr[3]}")
									s.close
									@descriptors.delete(s)
									if @users[s].game != nil
										@users[s].game.players.delete(s)
									end
									@users.delete(s)
								else
									#puts "#{req}"
									@users[s].perform("#{req}")
								end
							rescue
								if (s.closed? == false)
									s.close
								end
								@descriptors.delete(s)
								@users.delete(s)
							end
						end
					end
				end
				sleep( 0.001 )
			end
		end
	end
end

module Gamefic
	Theater.instance.scaffold "theaters/test.rb"
	x = Gamefic::Server.new
	x.run
end
