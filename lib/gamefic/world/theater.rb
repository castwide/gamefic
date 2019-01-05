Gamefic::World::Theater = Module.new do
  define_method :stage do |*args, &block|
    if block.nil?
      theater.instance_exec do
        eval *([args[0], theater.send(:binding)] + args[1..-1])
      end
    else
      theater.instance_exec *args, &block
    end
  end

  define_method :theater do
    @theater ||= begin
      instance = self
      theater ||= Object.new
      theater.instance_exec do
        define_singleton_method :method_missing do |symbol, *args, &block|
          instance.public_send :public_send, symbol, *args, &block
        end
      end
      theater
    end
  end
end
