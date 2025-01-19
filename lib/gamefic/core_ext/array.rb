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
    result = dup
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
    result = dup
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
  # @param separator [String] The separator for all but the last element
  # @param and_separator [String] The separator for the last element
  # @param serial [Boolean] Use serial separators (e.g., serial commas)
  # @return [String]
  def join_and(separator: ', ', and_separator: ' and ', serial: true)
    if length < 3
      join(and_separator)
    else
      start = self[0..-2]
      start.join(separator) + "#{serial ? separator.strip : ''}#{and_separator}#{last}"
    end
  end

  # @see Array#join_and
  #
  # @return [String]
  def join_or(separator: ', ', or_separator: ' or ', serial: true)
    join_and(separator: separator, and_separator: or_separator, serial: serial)
  end

  private

  def _keep(arr, cls, bool)
    case cls
    when Class, Module
      arr.keep_if { |i| i.is_a?(cls) == bool }
    when Proc
      arr.keep_if { |i| !!cls.call(i) == bool }
    else
      arr.keep_if { |i| (i == cls) == bool }
    end
  end
end
