class Array
  # Get a subset of the array that matches the argument.
  # If the argument is a Class or Module, the elements must be of the type.
  # If the argument is a Symbol, it should be a method for which the elements must return true.
  # If the argument is an Object, the elements must equal the object.
  #
  # @example
  #   animals = ['dog', 'cat', nil]
  #   animals.that_are(String) #=> ['dog', 'cat']
  #   animals.that_are('dog')  #=> ['dog']
  #   animals.that_are(:nil?)  #=> [nil]
  #
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

  # Get a subset of the array that does not match the argument.
  # See Array#that_are for information about how arguments are evaluated.
  #
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

  # Get a random element from the array.
  # @deprecated Use Array#sample instead.
  #
  def random
    return self[rand(self.length)]
  end

  # Pop a random element from the array.
  # @deprecated Use Array#pop_sample instead.
  #
  def pop_random
    pop_sample
  end

  # Pop a random element from the array.
  #
  def pop_sample
    delete_at(rand(self.length))
  end

  # Get a string representation of the array that separates elements with
  # commas and adds a conjunction before the last element.
  #
  # @example
  #   animals = ['a dog', 'a cat', 'a mouse']
  #   animals.join_and #=> 'a dog, a cat, and a mouse'
  #
  # @return [String]
  def join_and(sep = ', ', andSep = ' and ', serial = true)
    if self.length < 3
      self.join(andSep)
    else
      start = self[0..-2]
      start.join(sep) + "#{serial ? sep.strip : ''}#{andSep}#{self.last}"
    end
  end

  # @see Array#join_and
  #
  # @return [String]
  def join_or(sep = ', ', orSep = ' or ', serial = true)
    join_and(sep, orSep, serial)
  end
end
