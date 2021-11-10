module Battle
  module Effects
    # Implement the Protect effect
    class Protect < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move] move that applied this effect
      def initialize(logic, pokemon, move)
        super(logic, pokemon)
        @move = move
        self.counter = 1
      end

      # Function called when we try to check if the target evades the move
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] expected target
      # @param move [Battle::Move]
      # @return [Boolean] if the target is evading the move
      def on_move_prevention_target(user, target, move)
        return false if target != @pokemon
        return false unless move.blocked_by?(target, @move.db_symbol)

        play_protect_effect(user, target, move)
        return true
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :protect
      end

      private

      # Function responsive of playing the protect effect if protect got triggered (inc. message)
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] expected target
      # @param move [Battle::Move]
      def play_protect_effect(user, target, move)
        move.scene.display_message_and_wait(parse_text_with_pokemon(19, 523, target))
      end

      @effect_classes = {}

      class << self
        # Register a Protect effect
        # @param db_symbol [Symbol] db_symbol of the move
        # @param klass [Class<Protect>] protect class
        def register(db_symbol, klass)
          @effect_classes[db_symbol] = klass
        end

        # Create a new effect
        # @param logic [Battle::Logic]
        # @param pokemon [PFM::PokemonBattler]
        # @param move [Battle::Move] move that applied this effect
        # @return [Protect]
        def new(logic, pokemon, move)
          klass = @effect_classes[move.db_symbol] || Protect
          object = klass.allocate
          object.send(:initialize, logic, pokemon, move)
          return object
        end
      end

      # Implement the Spiky Shield effect
      class SpikyShield < Protect
        private

        # Function responsive of playing the protect effect if protect got triggered (inc. message)
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        def play_protect_effect(user, target, move)
          hp = user.hp / 8
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 523, target))
          move.scene.visual.show_hp_animations([user], [-hp]) if move.direct?
        end
      end
      Protect.register(:spiky_shield, SpikyShield)

      # Implement the King's Shield effect
      class KingsShield < Protect
        private

        # Function responsive of playing the protect effect if protect got triggered (inc. message)
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        def play_protect_effect(user, target, move)
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 523, target))
          move.scene.logic.stat_change_handler.stat_change_with_process(:atk, -1, user) if move.direct?
        end
      end
      Protect.register(:king_s_shield, KingsShield)

      # Implement the Baneful Bunker effect
      class BanefulBunker < Protect
        private

        # Function responsive of playing the protect effect if protect got triggered (inc. message)
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        def play_protect_effect(user, target, move)
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 523, target))
          handler = @logic.status_change_handler
          handler.status_change(:poison, user, message_overwrite: 234) if move.direct? && handler.status_appliable?(:poison, user)
        end
      end
      Protect.register(:baneful_bunker, BanefulBunker)

      # Implement the Mat Block effect
      class MatBlock < Protect
        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false if move.status?

          return super
        end
      end
      Protect.register(:mat_block, MatBlock)

      # Implement the Mat Block effect
      class Endure < PokemonTiedEffectBase
        # Create a new Pokemon tied effect
        # @param logic [Battle::Logic]
        # @param pokemon [PFM::PokemonBattler]
        # @param move [Battle::Move] move that applied this effect
        def initialize(logic, pokemon, move)
          super(logic, pokemon)
          @move = move
          @show_message = false
          self.counter = 1
        end

        # Function called when a damage_prevention is checked
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
        def on_damage_prevention(handler, hp, target, launcher, skill)
          return unless launcher && skill
          return if hp < target.hp
          return if target != @pokemon || dead?

          @show_message = true
          return target.hp - 1
        end

        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return unless @show_message

          @show_message = false
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 514, target))
          kill
        end
      end
      Protect.register(:endure, Endure)

      # Implement the Quick Guard effect
      class QuickGuard < Protect
        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false if @pokemon.bank != target.bank
          return false if move.relative_priority <= 0

          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 800, target))
          return true
        end
      end
      Protect.register(:quick_guard, QuickGuard)

      # Implement the Wide Guard effect
      class WideGuard < Protect
        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false if @pokemon.bank != target.bank
          return false if move.is_one_target?

          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 797, target))
          return true
        end
      end
      Protect.register(:wide_guard, WideGuard)
    end
  end
end
