module GameData
  # Window Builders
  #
  # Every constants should be Array of integer like this
  #    ConstName = [middle_tile_x, middle_tile_y, middle_tile_width, middle_tile_height,
  #                 contents_offset_left, contents_offset_top, contents_offset_right, contents_offset_bottom]
  module Windows
    MessageWindow = [16, 16, 8, 8, 16, 8]
    MessageHGSS = [14, 7, 8, 8, 16, 8]
    # List of awailable message frames
    # @return [Array<String>]
    MESSAGE_FRAME = %w[message m_1 m_2 m_3 m_4 m_5 m_6 m_7 m_8 m_9 m_10 m_11 m_12 m_13 m_14 m_15 m_16 m_17 m_18]
    # List of message frames names
    # @return [Array<String>]
    MESSAGE_FRAME_NAMES = %w[X/Y Gold Silver Red Blue Green Orange Purple Heart\ Gold Soul\ Silver Rocket Blue\ Indus
                             Red\ Indus Swamp Safari Brick Sea River B/W]
  end
end
