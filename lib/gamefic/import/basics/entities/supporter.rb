class Supporter < Thing

end

OptionSet.new(Supporter, :enterable).default = :not_enterable
OptionSet.set_default_for(Supporter, :not_portable)
