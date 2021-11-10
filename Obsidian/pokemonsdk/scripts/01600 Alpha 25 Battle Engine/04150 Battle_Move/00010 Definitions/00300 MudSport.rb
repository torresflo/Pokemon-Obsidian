module Battle
  class Move
    # Move that lower the power of electric/fire moves
    class MudSport < Move
      # List of effect depending on db_symbol of the move
      # @return [Hash{ Symbol => Class<Battle::Effects::EffectBase> }]
      EFFECT_KLASS = {}
      # List of message used to declare the effect
      # @return [Hash{ Symbol => Integer }]
      EFFECT_MESSAGE = {}

      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        if super
          effect_klass = EFFECT_KLASS[db_symbol]
          if logic.terrain_effects.each.any? { |effect| effect.class == effect_klass }
            show_usage_failure(user)
            return false
          end
          return true
        end

        return false
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        logic.terrain_effects.add(EFFECT_KLASS[db_symbol].new(@scene.logic))
        scene.display_message_and_wait(parse_text(18, EFFECT_MESSAGE[db_symbol]))
      end

      class << self
        # Register an effect to a "MudSport" like move
        # @param db_symbol [Symbol] Symbol of the move
        # @param klass [Class<Battle::Effects::EffectBase>]
        # @param message_id [Integer] ID of the message to show in file 18 when effect is applied
        def register_effect(db_symbol, klass, message_id)
          EFFECT_KLASS[db_symbol] = klass
          EFFECT_MESSAGE[db_symbol] = message_id
        end
      end

      register_effect(:mud_sport, Effects::MudSport, 120)
      register_effect(:water_sport, Effects::WaterSport, 118)
    end

    Move.register(:s_thing_sport, MudSport)
  end
end
