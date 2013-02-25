require "libx/carshuttle.rb"

action :drive do |actor|
	actor.state = Character::Drive
end
