module Battle
  module Effects
    class WonderRoom < EffectBase
      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      # @param duration [Integer] duration of the effect
      def initialize(logic, targets, duration)
        super(logic)
        @logic.scene.display_message_and_wait(parse_text(18, 184))
        @targets = targets
        self.counter = duration
        switch_stats
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, 185))
        switch_stats
      end

      def name
        :wonder_room
      end

      private

      # Switch the stats
      def switch_stats
        @targets.each do |target|
          next unless @logic.all_alive_battlers.include?(target)

          target.dfe_basis, target.dfs_basis = target.dfs_basis, target.dfe_basis
          log_error("#{target.name} Dfe:#{target.dfe_basis} Dfs:#{target.dfs_basis}")
        end
      end
    end
  end
end
