module Battle
  module Effects
    class Item
      class Berry < Item
        # List of berry flavors
        FLAVORS = %i[spicy dry sweet bitter sour]

        # Function that executes the effect of the berry (for Pluck & Bug Bite)
        # @param force_heal [Boolean] tell if a healing berry should force the heal
        def execute_berry_effect(force_heal: false)
          return nil
        end

        private

        # Function that consumes the berry
        # @param holder [PFM::PokemonBattler] pokemon holding the berry
        # @param launcher [PFM::PokemonBattler] potential user of the move
        # @param move [Battle::Move] potential move
        # @param should_confuse [Boolean] if the berry should confuse the Pokemon if he does not like the taste
        def consume_berry(holder, launcher = nil, move = nil, should_confuse: false)
          # TODO: show eating of berry
          @logic.item_change_handler.change_item(:none, true, holder, launcher, move) if holder.hold_item?(db_symbol)
          if should_confuse && (data = Yuki::Berries::BERRY_DATA[db_symbol])
            taste = FLAVORS.max_by { |flavor| data.send(flavor) } || FLAVORS.first
            return unless GameData::Flavors::DISLIKED_FLAVORS[taste].include?(holder.nature_id)
            return unless @logic.status_change_handler.status_appliable?(:confuse)

            @logic.status_change_handler.status_change(:confusion, holder)
          end
        end

        # Function that tests if berry cannot be consumed
        # @return [Boolean]
        def cannot_be_consumed?
          return @logic.foes_of(@target).any? { |foe| foe.has_ability?(:unnerve) && foe.alive? }
        end
      end
    end
  end
end
