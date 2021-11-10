module Battle
  module Effects
    class BatonPass < PokemonTiedEffectBase
      # Function called when a Pokemon has actually switched with another one
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(handler, who, with)
        switch_stages(handler, who, with)
        switch_status(handler, who, with)
        switch_effects(handler, who, with)
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :baton_pass
      end

      private

      # Switch the stages of the pokemons
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def switch_stages(handler, who, with)
        with.atk_stage, with.ats_stage, with.dfe_stage, with.dfs_stage, with.spd_stage, with.acc_stage, with.eva_stage = 
          who.atk_stage, who.ats_stage, who.dfe_stage, who.dfs_stage, who.spd_stage, who.acc_stage, who.eva_stage
      end

      # Switch the stages of the pokemons
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def switch_status(handler, who, with)
        handler.logic.status_change_handler.status_change_with_process(:confusion, with) if who.confused?
      end

      # Switch the effect from one to another
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def switch_effects(handler, who, with)
        who.effects.each do |effect|
          log_data("#{name} # passed #{effect.name}") if effect.on_baton_pass_switch(with)
        end
      end
    end
  end
end