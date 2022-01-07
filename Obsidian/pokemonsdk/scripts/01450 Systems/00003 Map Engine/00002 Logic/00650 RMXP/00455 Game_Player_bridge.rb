class Game_Player
  # Same as Game_Character but with Acro bike
  # @author Nuri Yuri
  def bridge_down_check(z)
    if z > 1 and !@__bridge
      if (sys_tag = front_system_tag) == BridgeUD or 
          (sys_tag == AcroBikeUD and (@on_acro_bike or $game_switches[::Yuki::Sw::EV_Bicycle]))
       @__bridge = [sys_tag, system_tag]
      end
    elsif z > 1 and @__bridge
      @__bridge = nil if @__bridge.last == system_tag and front_system_tag != @__bridge.first
    end
  end
  alias bridge_up_check bridge_down_check
  # Same as Game_Character but with Acro bike
  # @author Nuri Yuri
  def bridge_left_check(z)
    if z > 1 and !@__bridge
      if (sys_tag = front_system_tag) == BridgeRL or 
          (sys_tag == AcroBikeRL and (@on_acro_bike or $game_switches[::Yuki::Sw::EV_Bicycle]))
        @__bridge = [sys_tag, system_tag]
      end
    elsif z > 1 and @__bridge
      @__bridge = nil if @__bridge.last == system_tag and front_system_tag != @__bridge.first
    end
  end
  alias bridge_right_check bridge_left_check
end
