# Class describing game switches (events)
class Game_Switches < Array
  # The auto aliases start index
  # @return [Integer]
  AUTO_ALIAS_START_INDEX = 1000

  # Default initialization of game switches
  def initialize
    if $data_system
      super($data_system.switches.size, false)
    else
      super(200, false)
    end
  end

  # Create a symbol alias for a switch and return the id
  # @param id [Integer] the switch id
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
  # @param id [Integer] the id of the switch
  # @return [Boolean]
  def [](id)
    id = retrieve_id_from_alias(id) if id.is_a?(Symbol)
    return super(id)
  end

  # Setter
  # @param id [Integer] the id of the switch in the Array
  # @param value [Boolean] the new value of the switch
  def []=(id, value)
    id = retrieve_id_from_alias(id) if id.is_a?(Symbol)
    super(id, value)
  end

  # Converting game switches to bits
  def _dump(_level = 0)
    gsize = (size / 8 + 1)
    str = "\x00" * gsize
    gsize.times do |i|
      index = i * 8
      number = self[index] ? 1 : 0
      number |= 2 if self[index + 1]
      number |= 4 if self[index + 2]
      number |= 8 if self[index + 3]
      number |= 16 if self[index + 4]
      number |= 32 if self[index + 5]
      number |= 64 if self[index + 6]
      number |= 128 if self[index + 7]
      str.setbyte(i, number)
    end
    return str
  end

  # Loading game switches from the save file
  def self._load(args)
    var = Game_Switches.new
    args.size.times do |i|
      index = i * 8
      number = args.getbyte(i)
      var[index] = (number[0] == 1)
      var[index + 1] = (number[1] == 1)
      var[index + 2] = (number[2] == 1)
      var[index + 3] = (number[3] == 1)
      var[index + 4] = (number[4] == 1)
      var[index + 5] = (number[5] == 1)
      var[index + 6] = (number[6] == 1)
      var[index + 7] = (number[7] == 1)
    end
    return var
  end
end
