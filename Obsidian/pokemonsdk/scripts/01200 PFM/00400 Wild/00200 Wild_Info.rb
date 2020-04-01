module PFM
  # Wild remaining Pokemon group informations
  # @author Nuri Yuri
  class Wild_Info
    # The type of battle (1v1 2v2)
    # @return [Integer]
    attr_accessor :vs_type
    # The list of Pokemon ID
    # @return [Array<Integer>]
    attr_accessor :ids
    # The list of Pokemon level or Hash descriptor
    # @return [Array<Integer, Hash>]
    attr_accessor :levels
    # The list of chance to see the Pokemon (0 = delta level)
    # @return [Array<Integer>]
    attr_accessor :chances
    # Create a new Wild_Info object
    def initialize
      @vs_type=1
      @ids=Array.new
      @levels=Array.new
      @chances=Array.new(1,0)
    end
    # Get the delta_level attribute
    # @return [Integer]
    def delta_level
      return @chances[0]
    end
    # Change the delta_level attribute
    # @param v [Integer] the disparity in level
    def delta_level=(v)
      @chances[0]=v.to_i
    end
  end
end
