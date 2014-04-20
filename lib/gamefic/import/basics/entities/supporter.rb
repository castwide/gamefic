class Supporter < Thing

end

options(Supporter, :enterable).default = :not_enterable
set_default_for(Supporter, :not_portable)
