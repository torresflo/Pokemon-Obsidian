module Battle
  class Move
    # Move that inflict Autotomize to the enemy bank
    class Autotomize < Move
      private

      MODIFIERS = %i[atk_stage dfe_stage ats_stage dfs_stage spd_stage eva_stage acc_stage]
      # Function that deals the stat to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_stats(user, actual_targets)
        target_stats_before = actual_targets.map { |target| [target, MODIFIERS.map { |stat| target.send(stat) }] }.to_h
        result = super

        actual_targets.select! { |target| target_stats_before[target] != MODIFIERS.map { |stat| target.send(stat) } }

        return result && !actual_targets.empty?
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          # @type [Effects::Autotomize]
          if (effect = target.effects.get(:autotomize))
            effect.launch_effect(self)
          else
            target.effects.add(Effects::Autotomize.new(@logic, target, self))
          end
        end
      end
    end
    Move.register(:s_autotomize, Autotomize)
  end
end
