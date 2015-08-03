class Gamefic::Pathfinder
  attr_reader :origin, :destination, :path
  def initialize origin, destination
    @origin = origin
    @destination = destination
    @path = nil
    @paths = [[@origin]]
    @visited = []
    if @origin == @destination
      @path = []
    else
      while @path.nil? and @paths.length > 0
        embark
      end
    end
  end
  private
  def embark
    new_paths = []
    @paths.each { |path|
      last = path.last
      portals = last.children.that_are(Portal)
      portals.each { |portal|
        new_path = path.clone
        if !@visited.include?(portal.destination)
          new_path.push portal.destination
          @visited.push portal.destination
          if portal.destination == @destination
            @path = new_path
            @path.shift
            break
          end
          new_paths.push new_path
        end
      }
      path.push nil
    }
    @paths += new_paths
    @paths.delete_if{|path| path.last.nil?}
  end
end
