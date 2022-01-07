module PFM
  class Storage
    # Class Responsive of holding a team that can be used for battles
    class BattleBox
      # Name of the storage
      # @return [String]
      attr_accessor :name
      # Content of the storage
      # @return [Array<PFM::Pokemon>]
      attr_reader :content
      # Create a new battle box
      # @param name [String] name of the box
      # @param content_overload [Array] content to force in this object
      def initialize(name, content_overload = nil)
        @content = content_overload || Array.new(6)
        @name = name
      end
    end
  end
end
