module Battle
  class Visual
    # Animation of HP getting down/up
    class HPAnimation < Yuki::Animation::DiscreetAnimation
      # Create the HP Animation
      # @param scene [Battle::Scene] scene responsive of holding all the battle information
      # @param target [PFM::PokemonBattler] Pokemon getting its HP down/up
      # @param quantity [Integer] quantity of HP the Pokemon is getting
      def initialize(scene, target, quantity)
        @scene = scene
        @target = target
        @target_hp = (target.hp + (quantity == 0 ? -1 : quantity)).clamp(0, target.max_hp)
        diff = (target.hp - @target_hp).to_f
        super((diff / quantity).abs, target, :hp=, target.hp, @target_hp)
        start
      end

      # Update the animation
      def update
        super
        @scene.visual.refresh_info_bar(@target)
      end

      # Detect if the animation if done
      # @return [Boolean]
      def done?
        return false unless super

        @target.hp = @target_hp while @target_hp != @target.hp
        @scene.visual.refresh_info_bar(@target)
        return true
      end
    end
  end
end
