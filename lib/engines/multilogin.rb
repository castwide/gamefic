require "lib/engines/multitick"

module Gamefic
	class MultiLogin < MultiTick
		attr_reader :story
		def initialize(story)
			@story = story
			@server_socket = TCPServer.new('', 4141)
			@users = Array.new
		end
		def run
			last_tick = Time.new
			last_dec = 0
			while true
				resp = select([@server_socket], nil, nil, 0.001)
				if (resp != nil)
					for s in resp[0]
						# New connection
						n = @server_socket.accept
						puts ("Connection accepted from #{n.peeraddr[3]}")
						@users.push User.new(n, @story)
						# Experimenting with protocol modes... see http://stackoverflow.com/questions/4532344/send-data-over-telnet-without-pressing-enter
						n.send "#{255.chr}#{253.chr}#{34.chr}", 0
						n.send "#{255.chr}#{250.chr}#{34.chr}#{1.chr}#{0.chr}#{255.chr}#{240.chr}", 0
						n.send "#{255.chr}#{251.chr}#{1.chr}", 0
					end
				end
				diff = Time.new.to_f - last_tick.to_f
				if (diff * 10) >= last_dec
					@users.delete_if { |user| user.socket.closed? }
					last_dec = last_dec + 1
					@users.each { |user|
						user.update
					}
				end
				if diff >= 1.0
					@story.update
					last_tick = Time.new
					last_dec = 0
				end
				sleep( 0.001 )
			end
		end
		class User < Engine::User
			attr_reader :socket, :story
			attr_accessor :check_for_refresh
			def initialize(socket, story, state_class = Login)
				@socket = socket
				@story = story
				self.state = state_class
				@queue = Array.new
				@ip_address = @socket.peeraddr[3]
				#@check_for_updates = true
				@input_cache = ''
			end
			def send(message)
				begin
					@socket.send "#{message.gsub(/([^\r])\n/, "\\1\r\n")}", 0
					#@socket.send "#{message}", 0
				rescue
					print "Disconnecting user at #{@ip_address}\n"
					if @player != nil
						@player.disconnect
					end
					@socket.close
				end
			end
			def recv
				@queue.shift
			end
			def refresh
				if @check_for_refresh
					send "^refresh\n"
				end
			end
			def update
				resp = select([@socket], nil, nil, 0.001)
				if (resp != nil)
					for s in resp[0]
						data = s.recv(255)
						if (data == '')
							send "ERROR: Empty message.\n"
						else
							data.each_byte() { |c|
								# TODO: Handle special keys (e.g., arrows)
								if c == 255 or c == 27
									break
								elsif c == 127
									if @input_cache != ''
										@input_cache = @input_cache[0..-2]
										send c.chr
									end
								elsif c >= 32 and c < 255 # and c != 127
									@input_cache = @input_cache + c.chr
									send c.chr
								elsif c == 13
									@input_cache = @input_cache + "\n"
									send "\r\n"
								else
									# Other
								end
							}
							i = @input_cache.index("\n")
							while i != nil
								line = @input_cache.slice!(0..i)
								line.strip!
								if line == '^ping'
									send "^pong\n"
								elsif line == '^refresh'
									@check_for_refresh = true
								else
									@queue.push line
								end
								i = @input_cache.index("\n")
							end
						end
					end
				end
				@state.update
			end
		end
		class Login < Engine::State
			attr :username
			def post_initialize
				@user.send "Enter your name or NEW to create a new character: "
			end
			def update
				line = @user.recv
				if line != nil
					if line.downcase == "new"
						@user.state = NewUser
					else
						username = line
						@user.state = Password
					end
				end
			end
		end
		class Password < Engine::State
			def post_initialize
				@user.send "Password: "
			end
			def update
				line = @user.recv
				if line != nil
					# TODO: Authenticate login
					player = Player.new :name => @username
					@user.player = player
					@user.story.introduce player
					@user.state = Play
				end
			end
		end
		class NewUser < Engine::State
			def post_initialize
				@user.send "Select a name: "
			end
			def update
				line = @user.recv
				if line != nil
					@username = line
					@user.state = NewPassword
				end
			end
		end
		class NewPassword < Engine::State
			def post_initialize
				@user.send "Select a password: "
			end
			def update
				line = @user.recv
				if line != nil
					# TODO: Create an actual account
					player = Player.new :name => @username
					@user.player = player
					@user.story.introduce player
					@user.state = Play
				end
			end
		end
		class Play < Engine::State
			def post_initialize
				@user.send "Welcome!\n"
			end
			def update
				line = @user.recv
				if line != nil
					@user.player.perform line
				end
			end
		end
	end
end
