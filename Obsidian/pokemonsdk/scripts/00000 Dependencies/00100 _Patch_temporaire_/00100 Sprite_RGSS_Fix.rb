#encoding: utf-8

#noyard
class Sprite
  attr_accessor :blend_type
  attr_accessor :bush_depth
  attr_accessor :tone
  attr_accessor :color
  def flash(*args)
  end
  def update
  end
  def color
    return Color.new(0,0,0,0)
  end
  def tone
    return Tone.new(0,0,0,0)
  end
end
