require "lib/engine"
require "socket"

module Gamefic
	class MultiTick < Engine
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
			player.name = "player #{Time.new.usec}"
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
								begin
									s.send "ERROR: Empty message.\n", 0
								rescue
									puts ("Disconnecting user")
									s.close
									@descriptors.delete(s)
									@users.delete(s)
								end
							else
								if req.strip == '^ping'
									s.send "^pong\n", 0
								elsif req.strip == '^refresh'
									@users[s].check_for_refresh = true
								else
									lines = req.strip.split("\n")
									@users[s].queue.concat lines
								end
							end
						end
					end
				end
				sleep( 0.001 )
				diff = Time.new.to_f - @last_tick.to_f
				if (diff * 10) % 10 >= @last_dec
					@last_dec = @last_dec + 1
					@users.each { |socket, user|
						if user.player.state.class == Gamefic::Character::Ready
							while user.queue.length > 0
								command = user.queue.shift
								Director.dispatch(user.player, command)
								if user.player.state != Character::Ready
									break
								end
							end
						end
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
			attr_accessor :state, :name, :socket, :queue, :player, :check_for_refresh
			def initialize(socket, state_class = Play)
				@socket = socket
				self.state = state_class
				@queue = Array.new
				@check_for_updates = true
			end
			def state=(state_class)
				@state = state_class.new(self)
			end
			def send(message)
				if @socket.closed? == false
					@socket.send "#{message}", 0
				end
			end
			def puts(message)
				send "#{message}\n"
			end
			def recv
				#@queue.shift
			end
			def refresh
				if @check_for_refresh
					puts "^refresh"
				end
			end
			class Play < Engine::User::State
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
