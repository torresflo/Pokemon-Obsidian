module PFM
  class Storage
    # Class responsive of storing various thing and holding some information about the storage
    class Box
      # Name of the storage
      # @return [String]
      attr_accessor :name
      # Theme of the storage
      # @return [Integer]
      attr_accessor :theme
      # Content of the storage
      # @return [Array<PFM::Pokemon>]
      attr_reader :content
      # Create a new box
      # @param box_size [Integer] size of the box
      # @param name [String] name of the box
      # @param theme [Integer] theme of the box
      # @param content_overload [Array] content to force in this object
      def initialize(box_size, name, theme, content_overload = nil)
        @content = content_overload || Array.new(box_size)
        @name = name
        @theme = theme
      end
    end
  end
end
