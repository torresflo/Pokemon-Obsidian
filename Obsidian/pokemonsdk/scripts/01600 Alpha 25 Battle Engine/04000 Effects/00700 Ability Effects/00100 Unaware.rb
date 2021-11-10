module Battle
  module Effects
    class Ability
      class Unaware < Ability
        # Give the move [Spe]atk mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_atk_multiplier(user, target, move)
          return 1 if target != @target || move.critical_hit?
          return 1 unless user.can_be_lowered_or_canceled?
          return 1 / (move.physical? ? target.atk_modifier : target.ats_modifier) if move.is_a?(Move::FoulPlay)

          return 1 / (move.physical? ? user.atk_modifier : user.ats_modifier)
        end

        # Give the move [Spe]def mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_def_multiplier(user, target, move)
          return 1 if user != @target || move.critical_hit?
          return 1 unless target.can_be_lowered_or_canceled?

          return 1 / (move.physical? ? target.dfe_modifier : target.dfs_modifier)
        end

        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          if user == @target && target.can_be_lowered_or_canceled?
            return 1 / move.evasion_mod(target)
          elsif target == @target && user.can_be_lowered_or_canceled?
            return 1 / move.accuracy_mod(user)
          end

          return 1
        end
      end
      register(:unaware, Unaware)
    end
  end
end
