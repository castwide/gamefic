# frozen_string_literal: true

class Array
  # Get a subset of the array that matches the arguments.
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
  def that_are(*cls)
    result = clone
    cls.each do |c|
      _keep result, c, true
    end
    result
  end

  # Get a subset of the array that does not match the arguments.
  # See Array#that_are for information about how arguments are evaluated.
  #
  # @return [Array]
  def that_are_not(*cls)
    result = clone
    cls.each do |c|
      _keep result, c, false
    end
    result
  end

  # Pop a random element from the array.
  #
  def pop_sample
    delete_at(rand(length))
  end

  # Get a string representation of the array that separates elements with
  # commas and adds a conjunction before the last element.
  #
  # @example
  #   animals = ['a dog', 'a cat', 'a mouse']
  #   animals.join_and #=> 'a dog, a cat, and a mouse'
  #
  # @param sep [String] The separator for all but the last element
  # @param andSep [String] The separator for the last element
  # @param serial [Boolean] Use serial separators (e.g., serial commas)
  # @return [String]
  def join_and(sep = ', ', and_sep = ' and ', serial = true)
    if length < 3
      join(and_sep)
    else
      start = self[0..-2]
      start.join(sep) + "#{serial ? sep.strip : ''}#{andSep}#{last}"
    end
  end

  # @see Array#join_and
  #
  # @return [String]
  def join_or(sep = ', ', or_sep = ' or ', serial = true)
    join_and(sep, or_sep, serial)
  end

  private

  def _keep(arr, cls, bool)
    case cls
    when Class, Module
      arr.keep_if { |i| i.is_a?(cls) == bool }
    when Symbol
      arr.keep_if { |i| i.send(cls) == bool }
    else
      arr.keep_if { |i| (i == cls) == bool }
    end
  end
end
