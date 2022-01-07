class Game_Player
  # Return the tail of the following queue (Game_Event exclusive)
  # @return [Game_Character, self]
  def follower_tail
    return self unless (current_follower = @follower)
    return self unless current_follower.is_a?(Game_Event)
    while (next_follower = current_follower.follower)
      break unless next_follower.is_a?(Game_Event)
      current_follower = next_follower
    end
    return current_follower
  end

  # Define the follower of the player, if the player already has event following him, it'll put them at the tail of the following events
  # @param follower [Game_Character, Game_Event] the follower
  # @param force [Boolean] param comming from Yuki::FollowMe to actually force the follower
  # @author Nuri Yuri
  def set_follower(follower, force = false)
    return @follower = follower if force
    return reset_follower unless follower
    return if @follower == follower
    return @follower = follower unless @follower
    # If the instance_variable is a game event we put the event at the end of the queue
    return follower_tail.set_follower(follower) if @follower.is_a?(Game_Event)
    # If the follower wasn't Game_Event but the current one is
    follower.set_follower(@follower) if follower.is_a?(Game_Event)
    @follower = follower
  end

  # Reset the follower stack to prevent any issue
  def reset_follower
    return unless (current_follower = @follower)

    while (next_follower = current_follower.follower)
      current_follower.set_follower(nil)
      current_follower = next_follower
    end
    @follower = nil
  end

  # Set the player z and all its follower z at the same tile
  # @param value [Integer] new z value
  def change_z_with_follower(value)
    @z = value
    follower = self
    while follower = follower.follower
      follower.z = value
    end
  end
end
