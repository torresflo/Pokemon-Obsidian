module BattleUI
  # Sprite of a Trainer in the battle
  class ItemBar < AbilityBar
    private

    def create_text
      add_text(*text_coordinates, 0, 16, :item_name, color: 10, type: SymText)
    end
  end
end
