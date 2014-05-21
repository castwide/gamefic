module Gamefic

  class Meta < Action
    def initialize *args
      super
      @plot.before @command, *@queries do |*args|
        @plot.pass :everything
      end
    end
  end
  
end
