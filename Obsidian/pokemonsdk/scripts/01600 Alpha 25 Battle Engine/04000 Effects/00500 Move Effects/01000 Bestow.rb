module Battle
  module Effects
    class Bestow < EffectBase
      # Initialize the effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      # @param giver [PFM::PokemonBattler] the Pokemon that gives the item
      # @param receiver [PFM::PokemonBattler] the Pokemon that receives the item
      # @param item [Symbol] the db_symbol of the item
      def initialize(logic, giver, receiver, item)
        super(logic)
        @giver = giver
        @receiver = receiver
        @item = item
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :bestow
      end

      # Give the item back to the giver and clear the item of the receiver
      def give_back_item
        return if @receiver.bank != 0 && !@logic.battle_info.trainer_battle?

        @logic.item_change_handler.change_item(item, true, @giver)
        @logic.item_change_handler.change_item(:none, true, @receiver)
      end
    end
  end
end
