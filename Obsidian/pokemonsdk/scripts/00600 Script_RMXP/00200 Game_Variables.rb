# Class that describe game variables
class Game_Variables < Array
  # The auto aliases start index
  # @return [Integer]
  AUTO_ALIAS_START_INDEX = 1000

  # default initialization of game variables
  def initialize
    if $data_system
      super($data_system.variables.size, 0)
    else
      super(200, 0)
    end
  end

  # Create a symbol alias for a variable and return the id
  # @param id [Integer] the variable id
  # @param sym [Symbol] the alias symbol
  # @return [Integer]
  def create_alias(id, sym)
    # Create the aliases storage
    @aliases ||= {}
    # Create the alias
    @aliases[sym] = id unless @aliases.key?(sym)
    # Return the id
    return id
  end

  # Retrieve an id from alias, create the id if the alias doesn't exist. Auto ids start at AUTO_ALIAS_START_INDEX.
  # @param sym [Symbol] the alias
  # @return [Integer]
  def retrieve_id_from_alias(sym)
    return @aliases[sym] if @aliases&.key?(sym)

    id = create_alias([AUTO_ALIAS_START_INDEX, size].max, sym)
    log_debug("Automatic alias creation : #{sym.inspect} => #{id}")
    return id
  end

  # Getter
  # @param index [Integer] the index of the variable
  # @note return 0 if the variable is outside of the array.
  def [](index)
    index = retrieve_id_from_alias(index) if index.is_a?(Symbol)
    return 0 if size <= index
    super(index)
  end

  # Setter
  # @param index [Integer] the index of the variable in the Array
  # @param value [Integer] the new value of the variable
  def []=(index, value)
    unless value.is_a?(Integer)
      raise TypeError, "Unexpected #{value.class} value. $game_variables store numbers and nothing else, use $option to store anything else."
    end
    index = retrieve_id_from_alias(index) if index.is_a?(Symbol)
    super(size, 0) while size < index
    super(index, value)
  end
end
