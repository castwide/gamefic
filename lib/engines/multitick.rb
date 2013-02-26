require "lib/engine"
require "socket"

module Gamefic
	class MultiTick < Engine
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
						#n.send "#{255.chr}#{253.chr}#{34.chr}", 0
						#n.send "#{255.chr}#{250.chr}#{34.chr}#{1.chr}#{0.chr}#{255.chr}#{240.chr}", 0
						#n.send "#{255.chr}#{251.chr}#{1.chr}", 0
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
			def initialize(socket, story, state_class = Welcome)
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
					# The commented line forces \r\n for the dynamo version of telnet
					#@socket.send "#{message.gsub(/([^\r])\n/, "\\1\r\n")}", 0
					@socket.send "#{message}", 0
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
						if data[0] == 255
							puts "Filtering negotiation."
						else
							if (data == '')
								send "ERROR: Empty message.\n"
							else
								#data.gsub!(/\r/, "\n")
								#send data
								#data.gsub!(/\r\n/, "\n")
								@input_cache = @input_cache + data
								#if data.include?("\r")
								#	@input_cache = @input_cache + "\n"
								#	send "\n"
								#end
								i = @input_cache.index("\n")
								@input_cache.gsub!(/\r/, "")
								while i != nil
									line = @input_cache.slice!(0..i)
									line.strip!
									if line.strip == '^ping'
										send "^pong\n"
									elsif line.strip == '^refresh'
										@check_for_refresh = true
									else
										@queue.push line
									end
									i = @input_cache.index("\n")
								end
							end
						end
					end
				end
				@state.update
			end
		end
		class Welcome < Engine::State
			def post_initialize
				@user.send "Enter your name:"
			end
			def update
				line = @user.recv
				if line != nil
					@user.send "Welcome, #{line}.\n"
					player = Player.new :name => line
					@user.player = player
					@user.story.introduce player
					@user.state = Play
				end
			end
		end
		class Play < Engine::State
			def post_initialize
				# nothing to do
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
