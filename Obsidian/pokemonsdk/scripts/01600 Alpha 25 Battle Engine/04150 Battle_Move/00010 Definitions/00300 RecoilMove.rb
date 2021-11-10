module Battle
  class Move
    # Move that has a little recoil when it hits the opponent
    class RecoilMove < Basic
      # List of factor depending on the move
      RECOIL_FACTORS = {
        brave_bird: 3,
        double_edge: 3,
        flare_blitz: 3,
        head_charge: 4,
        head_smash: 2,
        light_of_ruin: 2,
        shadow_end: 2,
        shadow_rush: 16,
        struggle: 4,
        submission: 4,
        take_down: 4,
        volt_tackle: 3,
        wild_charge: 4,
        wood_hammer: 3
      }

      # Tell that the move is a recoil move
      # @return [Boolean]
      def recoil?
        true
      end

      # Returns the recoil factor
      # @return [Integer]
      def recoil_factor
        RECOIL_FACTORS[db_symbol] || super
      end

      # Test if the recoil applies to user max hp
      def recoil_applies_on_user_max_hp?
        %i[struggle shadow_rush].include?(db_symbol)
      end

      # Test if teh recoil applis to user current hp
      def recoil_applies_on_user_hp?
        %i[shadow_end].include?(db_symbol)
      end

      # Function applying recoil damage to the user
      # @param hp [Integer]
      # @param user [PFM::PokemonBattler]
      def recoil(hp, user)
        hp = user.max_hp if recoil_applies_on_user_max_hp?
        hp = user.hp if recoil_applies_on_user_hp?
        super(hp, user)
      end
    end

    # Struggle Move
    class Struggle < RecoilMove
      # Get the types of the move with 1st type being affected by effects
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Array<Integer>] list of types of the move
      def definitive_types(user, target)
        [0]
      end
    end

    Move.register(:s_recoil, RecoilMove)
    Move.register(:s_struggle, Struggle)
  end
end
