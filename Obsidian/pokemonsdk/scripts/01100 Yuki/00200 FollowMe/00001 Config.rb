module Yuki
  module FollowMe
    module_function

    # Tell if the system is enabled or not
    # @return [Boolean]
    def enabled
      $game_switches[Sw::FM_Enabled]
    end

    # Enable or disabled the system
    # @param state [Boolean] new enabled state
    def enabled=(state)
      $game_switches[Sw::FM_Enabled] = state
    end

    # Get the current selected follower (to move using player moveroutes)
    # @return [Integer] 0 = no follower selected
    def selected_follower
      $game_variables[Var::FM_Sel_Foll]
    end

    # Set the selected follower
    # @param index1 [Integer] index of the follower in the follower stack starting at index 1
    def selected_follower=(index1)
      $game_variables[Var::FM_Sel_Foll] = index1.clamp(0, @followers.size)
    end

    # Get the number of human following the player (Heroes from 2 to n+1)
    # @return [Integer]
    def human_count
      $game_variables[Var::FM_N_Human]
    end

    # Set the number of human following the player
    # @param count [Integer] number of human
    def human_count=(count)
      $game_variables[Var::FM_N_Human] = count
    end

    # Get the number of pokemon following the player
    # @return [Integer]
    def pokemon_count
      $game_variables[Var::FM_N_Pokem]
    end

    # Set the number of pokemon following the player
    # @param count [Integer]
    def pokemon_count=(count)
      $game_variables[Var::FM_N_Pokem] = count
    end

    # Get the number of Pokemon from "other_party" following the player
    # @return [Integer]
    def other_pokemon_count
      $game_variables[Var::FM_N_Friend]
    end

    # Set the number of Pokemon from "other_party" following the player
    # @param count [Integer]
    def other_pokemon_count=(count)
      $game_variables[Var::FM_N_Friend] = count
    end

    # Is the FollowMe in Let's Go Mode
    # @return [Boolean]
    def in_lets_go_mode?
      $game_switches[Sw::FollowMe_LetsGoMode]
    end

    # Set the FollowMe Let's Go Mode state
    # @param mode [Boolean] true if in lets go mode
    def lets_go_mode=(mode)
      $game_switches[Sw::FollowMe_LetsGoMode] = mode
    end
  end
end
