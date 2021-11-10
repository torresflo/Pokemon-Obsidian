module Battle
  module AI
    class Base
      private

      # Get the move heuristic for a move
      # @param move [Battle::Move]
      # @return [AI::MoveHeuristicBase]
      def move_heuristic_object(move)
        @move_heuristic_cache[move]
      end

      # List all the possible action for a move
      # @param move [Battle::Move]
      # @param pokemon [PFM::PokemonBattler]
      # @return [Array<[Float, Battle::Actions::Base]>]
      def move_action_for(move, pokemon)
        targets = filter_targets(move.battler_targets(pokemon, @scene.logic), pokemon, move)
        actions = targets.map do |battler|
          [move_heuristic(move, pokemon, battler), Actions::Attack.new(@scene, move, pokemon, battler.bank, battler.position)]
        end
        actions = group_move_action(actions) unless move.one_target?

        return actions.shuffle(random: @scene.logic.generic_rng).max_by(&:first)
      end

      # Process the move heuristic
      # @param move [Battle::Move]
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Float]
      def move_heuristic(move, user, target)
        heuristic = 1.0
        move_heuristic = move_heuristic_object(move)
        effectiveness = @can_see_effectiveness && !move_heuristic.ignore_effectiveness? ? move_effectiveness(move, user, target) : 1.0
        heuristic *= move_power(move, user, target, effectiveness) if @can_see_power && !move_heuristic.ignore_power?
        heuristic *= move_heuristic.compute(move, user, target, self) if @can_see_move_kind || move_heuristic.overwrite_move_kind_flag?
        return heuristic
      end

      # Process the move effectiveness
      # @param move [Battle::Move]
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Float]
      def move_effectiveness(move, user, target)
        # Stab => 1 ~ 2
        # type_modifier => 0.125 ~ 8
        # SQRT(Stab * type_modifier) => 0.354 ~ 4
        effectiveness = Math.sqrt(move.calc_stab(user, move.definitive_types(user, target)) * move.type_modifier(user, target))
        return effectiveness == 0 ? 0 : 1.0 if move.status?

        return effectiveness
      end

      # Process the move power
      # @param move [Battle::Move]
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @param effectiveness [Float]
      # @return [Float]
      def move_power(move, user, target, effectiveness)
        if move.status?
          return effectiveness if move.respond_to?(:special_ai_modifier) && @can_see_move_kind

          return Math.exp((user.last_sent_turn - $game_temp.battle_turn + 1) / 10.0) * effectiveness * 0.85
        end

        # Constrict: 10 + lowest effectiveness => 0.750885
        # Explosion: 250 + best effectiveness => 1.0
        return 0.75 + move.real_base_power(user, target) * effectiveness / 4000
      end

      # Group the move actions when they're hitting several targets
      # @param actions [Array]
      # @return [Array]
      def group_move_action(actions)
        return actions if actions.empty?

        action = actions.first.last
        heuristic = actions.reduce(0) { |sum, curr| sum + curr.first } / actions.size
        return [[heuristic, action]]
      end

      # Filter the target a move can aim
      # @param targets [Array<PFM::PokemonBattler>]
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @return [Array<PFM::PokemonBattler>]
      def filter_targets(targets, pokemon, move)
        alive_targets = targets.select(&:alive?)
        return [alive_targets.sample || targets.sample(random: @scene.logic.generic_rng)].compact if move.target == :random_foe
        return targets if move.no_choice_skill? || !move.one_target?

        no_bank_target = alive_targets.reject { |battler| battler.bank == @bank }
        if @can_choose_target
          return no_bank_target.empty? ? targets : no_bank_target
        else
          return [(no_bank_target.empty? ? targets : no_bank_target).sample(random: @scene.logic.generic_rng)].compact
        end
      end
    end
  end
end
