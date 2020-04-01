# The RGSS Audio module
module Audio
  @music_volume = 100
  @sfx_volume = 100

  module_function

  # Get volume of bgm and me
  # @return [Integer] a value between 0 and 100
  def music_volume
    return @music_volume
  end

  # Set the volume of bgm and me
  # @param value [Integer] a value between 0 and 100
  def music_volume=(value)
    value = value.to_i.abs
    @music_volume = value < 101 ? value : 100
  end

  # Get volume of sfx
  # @return [Integer] a value between 0 and 100
  def sfx_volume
    return @sfx_volume
  end

  # Set the volume of sfx
  # @param value [Integer] a value between 0 and 100
  def sfx_volume=(value)
    value = value.to_i.abs
    @sfx_volume = value < 101 ? value : 100
  end

  # A weird alias of #se_play
  def cry_play(filename, volume = 100, pitch = 100)
    se_play(filename, volume, pitch)
  end

  # Tells if a cry file exists or not
  # @param filename [String] the name of the cry file
  # @return [Boolean]
  def cry_exist?(filename)
    return File.exist?(filename)
  end
end
