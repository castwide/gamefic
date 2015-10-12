class Array
  # @return [Array]
  def that_are(cls)
    if (cls.kind_of?(Class) or cls.kind_of?(Module))
      return self.clone.delete_if { |i| i.kind_of?(cls) == false }
    elsif cls.kind_of?(Symbol)
      return self.clone.delete_if { |i| i.send(cls) == false }      
    else
      if self.include?(cls)
        return [cls]
      end
      return Array.new
    end
  end
  # @return [Array]
  def that_are_not(cls)
    if (cls.kind_of?(Class) or cls.kind_of?(Module))
      return self.clone.delete_if { |i| i.kind_of?(cls) == true }
    elsif cls.kind_of?(Symbol)
      return self.clone.delete_if { |i| i.send(cls) == true }
    else
      return self.clone - [cls]
    end
  end
  def random
    return self[rand(self.length)]
  end
  def pop_random
    delete_at(rand(self.length))
  end
  # @return [Array]
  def shuffle
    self.sort { |a, b|
      rand(3) <=> rand(3)
    }
  end
  # @return [Array]
  def shuffle!
    self.sort! { |a, b|
      rand(3) <=> rand(3)
    }
  end
  # Get a string representation of the array that separated elements with
  # commas and adds a conjunction before the last element.
  # @return [String]
  def join_and(sep = ', ', andSep = ' and ', serial = true)
    if self.length < 3
      self.join(andSep)
    else
      start = self - [self.last]
      start.join(sep) + "#{serial ? sep.strip : ''}#{andSep}#{self.last}"
    end
  end
  # @return [String]
  def join_or(sep = ', ', orSep = ' or ', serial = true)
    join_and(sep, orSep, serial)
  end
end
