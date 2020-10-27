module Battle
  class Visual
    # Animation of HP getting down/up
    class HPAnimation < Yuki::Animation::DiscreetAnimation
      # Create the HP Animation
      # @param scene [Battle::Scene] scene responsive of holding all the battle information
      # @param target [PFM::PokemonBattler] Pokemon getting its HP down/up
      # @param quantity [Integer] quantity of HP the Pokemon is getting
      # @param effectiveness [Integer, nil] optional param to play the effectiveness sound if that comes from using a move
      def initialize(scene, target, quantity, effectiveness = nil)
        @scene = scene
        @target = target
        @target_hp = (target.hp + (quantity == 0 ? -1 : quantity)).clamp(0, target.max_hp)
        diff = (target.hp - @target_hp).to_f
        super((diff / quantity).abs, target, :hp=, target.hp, @target_hp)
        start
        effectiveness_sound(effectiveness) if quantity != 0 && effectiveness
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

      # Play the effectiveness sound
      def effectiveness_sound(effectiveness)
        if effectiveness == 1
          Audio.se_play('Audio/SE/hit')
        elsif effectiveness > 1
          Audio.se_play('Audio/SE/hitplus')
        else
          Audio.se_play('Audio/SE/hitlow')
        end
      end
    end
  end
end
