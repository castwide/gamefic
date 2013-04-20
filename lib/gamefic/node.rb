module Gamefic

	module Node
		def children
			if @children == nil
				@children = Array.new
			end
			@children.clone
		end
		def flatten
			array = Array.new
			children.each { |child|
				array = array + recurse_flatten(child)
			}
			return array
		end
		protected
		def add_child(node)
			children
			@children.push(node)
		end
		def rem_child(node)
			children
			@children.delete(node)
		end
		def concat_children(children)
			children
			@children.concat(children)
		end
		private
		def recurse_flatten(node)
			array = Array.new
			array.push(node)
			node.children.each { |child|
				array = array + recurse_flatten(child)
			}
			return array
		end
	end
	
	module Branch
		include Node
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
