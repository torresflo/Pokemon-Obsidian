module UI
  module Storage
    # Background of the box
    class BoxBackground < ShaderedSprite
      # Get current box data
      # @return [PFM::Storage::Box]
      attr_reader :data

      # Set current box data
      # @param box [PFM::Storage::Box]
      def data=(box)
        set_bitmap(format('pc/f_%<theme>d', theme: box.theme), :interface)
      end
    end
  end
end
