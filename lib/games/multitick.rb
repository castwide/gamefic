require "socket"

module Gamefic
	class MultiTick < Game
		attr_reader :story
		def initialize(story)
			@story = story
			@serverSocket = TCPServer.new('', 4141)
			@descriptors = Array.new
			@descriptors.push(@serverSocket)
			@users = Hash.new
		end
		def enroll(user)
			@users[user.socket] = user
			player = Player.new
			player.parent = @story
			player.name = "player"
			player.connect user
			@story.introduce player
			user.player = player
		end
		def run
			@last_tick = Time.new
			@last_dec = 0
			while true
				resp = select(@descriptors, nil, nil, 0.001)
				if (resp != nil)
					for s in resp[0]
						if (s == @serverSocket)
							# New connection
							n = @serverSocket.accept
							puts ("Connection accepted from #{n.peeraddr[3]}")
							@descriptors.push(n)
							enroll User.new(n)
						else
							req = s.recv(255)
							if (req == '')
								puts ("Disconnecting user")
								s.close
								@descriptors.delete(s)
								@users.delete(s)
							else
								puts "Command received: #{req}"
								@users[n].queue.push req
								#@users[n].player.perform req
							end
						end
					end
				end
				sleep( 0.001 )
				diff = Time.new.to_f - @last_tick.to_f
				if (diff * 10) % 10 >= @last_dec
					@last_dec = @last_dec + 1
					@users.each { |socket, user|
						user.player.flush
					}				
				end
				if diff >= 1.0
					@story.update
					@last_tick = Time.new
					@last_dec = 0
				end
			end
		end
		class User
			attr_accessor :state, :name, :socket, :queue, :player
			def initialize(socket, state_class = Play)
				@socket = socket
				self.state = state_class
				@queue = Array.new
			end
			def state=(state_class)
				@state = state_class.new(self)
			end
			def send(message)
				if @socket.closed? == false
					@socket.send "#{message}\0", 0
				end
			end
			def puts(message)
				send "#{message}\n"
			end
			def recv
				#@queue.shift
			end
			class Play < Game::User::State
				def post_initialize
					# nothing to do
				end
				def update
					# nothing to do
				end
			end
		end
	end
end
