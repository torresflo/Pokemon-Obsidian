module Battle
  class Move
    # Move that share HP between targets
    class PainSplit < Move
      # Check if the move bypass chance of hit and cannot fail
      # @param _user [PFM::PokemonBattler] user of the move
      # @param _target [PFM::PokemonBattler] target of the move
      # @return [Boolean]
      def bypass_chance_of_hit?(_user, _target)
        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        hp_total = 0
        actual_targets = [user].concat(actual_targets)
        actual_targets.each { |target| hp_total += target.effects.has?(:substitute) ? target.effects.get(:substitute).hp : target.hp }
        hp_total = (hp_total / actual_targets.size).to_i
        scene.display_message_and_wait(message)
        actual_targets.each do |target|
          if target.effects.has?(:substitute)
            substitute = target.effects.get(:substitute)
            substitute.hp = hp_total.clamp(1, substitute.max_hp)
          else
            scene.visual.show_hp_animations([target], [hp_total - target.hp])
          end
        end
      end

      # Get the message
      def message
        return parse_text(18, 117)
      end
    end
    Move.register(:s_pain_split, PainSplit)
  end
end
