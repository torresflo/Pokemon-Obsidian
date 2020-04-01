module PFM
  # Battler recorder object
  # @author Nuri Yuri
  class MagnetoVS
    # The first party array
    # @return [Array<PFM::Pokemon>]
    attr_reader :party1
    # The second party array
    # @return [Array<PFM::Pokemon>]
    attr_reader :party2
    # The list of enemy names
    # @return [Array<String>]
    attr_reader :names
    # Create a new MagnetoVS object
    # @param party1 [Array<PFM::Pokemon>] the first party array
    # @param party2 [Array<PFM::Pokemon>] the second party array
    # @param names [Array<String>] the list of enemy names
    def initialize(party1, party2, names)
      @party1 = Marshal.load(Marshal.dump(party1))
      @party2 = Marshal.load(Marshal.dump(party2))
      @names = names
      @action_stack = []
      @index = 0
      @recording = true
    end

    # Start playing the battle
    # @return [Boolean] if the battle can be played
    def play
      return false if @recording
      @index = 0
      return true
    end

    # Add a seed to the action stack
    # @param seed [Integer] a seed
    def push_seed(seed)
      return unless @recording
      @action_stack << seed
    end

    # Add an action  to the action stack
    # @param data [Array] the action data
    # @param party [1, 2] the party id (party1 or party2)
    def push_actions(data, party = 1)
      return unless @recording
      pkmn = nil
      party = party == 1 ? @party1 : @party2
      data = Marshal.load(Marshal.dump(data))
      data.each do |i|
        if(i[0] == 0)
          pkmn = i[3]
           index = party.index(i[3]).to_i
          i[3] = party[index]
        end
      end
      @action_stack << data
    end

    # Add a switch action to the stack
    def push_switch(data)
      return unless @recording
      @action_stack << data
    end

    # Return an action (playing) and next time return the next action
    # @return [Array, nil]
    def get_action
      return nil if @recording
      action = @action_stack[@index]
      @index += 1
      return action
    end

    # Is the battle finished ?
    # @return [Boolean]
    def done_playing?
      return @index >= @action_stack.size
    end

    # Tell the recorder that the record is done (play will work then)
    def done
      @recording = false
    end
  end
end
