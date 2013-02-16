module Gamefic

	module Node
		def children
			@children ||= Array.new
		end
		protected
		def add_child(node)
			children.push(node)
		end
		def rem_child(node)
			children.delete(node)
		end
		def concat_children(children)
			children.concat(children)
		end
	end
	
	class Root
		include Node
		def root
			self
		end
		def family
			children.flatten
		end
	end

	module Branch
		include Node
		def root
			parent != nil ? parent.root : nil
		end
		def parent
			@parent
		end
		def parent=(node)
			if node == self
				raise "Entity cannot be its own parent"
			end
			if @parent != node
				if @parent != nil
					@parent.send(:rem_child, self)
				end
				@parent = node
				if @parent != nil
					@parent.send(:add_child, self)
				end
			end
		end
	end

end
