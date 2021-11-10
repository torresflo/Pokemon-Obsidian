module Battle
  class Logic
    # Get a new stat change handler
    # @return [Battle::Logic::StatChangeHandler]
    def stat_change_handler
      return StatChangeHandler.new(self, @scene)
    end

    # Get a new item change handler
    # @return [Battle::Logic::ItemChangeHandler]
    def item_change_handler
      return ItemChangeHandler.new(self, @scene)
    end

    # Get a new item change handler
    # @return [Battle::Logic::StatusChangeHandler]
    def status_change_handler
      return StatusChangeHandler.new(self, @scene)
    end

    # Get a new damage handler
    # @return [Battle::Logic::DamageHandler]
    def damage_handler
      return DamageHandler.new(self, @scene)
    end

    # Get a new switch handler
    # @return [Battle::Logic::SwitchHandler]
    def switch_handler
      return SwitchHandler.new(self, @scene)
    end

    # Get a new switch handler
    # @return [Battle::Logic::EndTurnHandler]
    def end_turn_handler
      return EndTurnHandler.new(self, @scene)
    end

    # Get a new weather change handler
    # @return [Battle::Logic::WeatherChangeHandler]
    def weather_change_handler
      return WeatherChangeHandler.new(self, @scene)
    end

    # Get a new field terrain change handler
    # @return [Battle::Logic::FTerrainChangeHandler]
    def fterrain_change_handler
      return FTerrainChangeHandler.new(self, @scene)
    end

    # Get the flee handler
    # @return [Battle::Logic::FleeHandler]
    def flee_handler
      return FleeHandler.new(self, @scene)
    end

    # Get the catch handler
    # @return [Battle::Logic::CatchHandler]
    def catch_handler
      return CatchHandler.new(self, @scene)
    end

    # Get the ability change handler
    # @return [Battle::Logic::AbilityChangeHandler]
    def ability_change_handler
      return AbilityChangeHandler.new(self, @scene)
    end

    # Get the battle end handler
    # @return [Battle::Logic::BattleEndHandler]
    def battle_end_handler
      return BattleEndHandler.new(self, @scene)
    end

    # Get the exp handler
    # @return [Battle::Logic::ExpHandler]
    def exp_handler
      return ExpHandler.new(self)
    end

    # Get the transform handler
    # @return [Battle::Logic::TransformHandler]
    def transform_handler
      return TransformHandler.new(self, @scene)
    end
  end
end
