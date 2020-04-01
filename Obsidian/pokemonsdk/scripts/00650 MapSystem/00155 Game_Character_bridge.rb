class Game_Character
  # Adjust the Character informations related to the brige when it moves down (or up)
  # @param z [Integer] the z position
  # @author Nuri Yuri
  def bridge_down_check(z)
    if z > 1 and !@__bridge
      if (sys_tag = front_system_tag) == BridgeUD
        @__bridge = [sys_tag, system_tag]
      end
    elsif z > 1 and @__bridge
      @__bridge = nil if @__bridge.last == system_tag
    end
  end
  alias bridge_up_check bridge_down_check

  # Adjust the Character informations related to the brige when it moves left (or right)
  # @param z [Integer] the z position
  # @author Nuri Yuri
  def bridge_left_check(z)
    if z > 1 and !@__bridge
      if (sys_tag = front_system_tag) == BridgeRL
        @__bridge = [sys_tag, system_tag]
      end
    elsif z > 1 and @__bridge
      @__bridge = nil if @__bridge.last == system_tag
    end
  end
  alias bridge_right_check bridge_left_check

  # Check bridge information and adjust the z position of the Game_Character
  # @param sys_tag [Integer] the SystemTag
  # @author Nuri Yuri
  def z_bridge_check(sys_tag)
    @z = ZTag.index(sys_tag) if ZTag.include?(sys_tag)
    @z = 1 if @z < 1
    @z = 0 if @z == 1 and BRIDGE_TILES.include?(sys_tag)
    @__bridge = nil if @__bridge and @__bridge.last == sys_tag
  end
end