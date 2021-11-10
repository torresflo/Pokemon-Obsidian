module Battle
  class Move
    # Class managing the Incinerate move
    class Incinerate < Basic
      BURNABLE_ITEMS = %i[
        fire_gem water_gem electric_gem grass_gem ice_gem fighting_gem poison_gem ground_gem flying_gem
        psychic_gem bug_gem rock_gem ghost_gem dragon_gem dark_gem steel_gem normal_gem fairy_gem
      ]

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if user.dead?

        actual_targets.each do |target|
          next unless @logic.item_change_handler.can_lose_item?(target, user)
          next unless target.hold_berry?(target.battle_item_db_symbol) || BURNABLE_ITEMS.include?(target.battle_item_db_symbol)

          @scene.display_message_and_wait(parse_text_with_pokemon(19, 1114, target, PFM::Text::ITEM2[1] => target.item_name))
          target.item_burnt = true
        end
      end
    end
    Move.register(:s_incinerate, Incinerate)
  end
end
